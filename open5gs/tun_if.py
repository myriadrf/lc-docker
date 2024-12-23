# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
#               2024, AB Open Ltd
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import yaml
import click
import subprocess
import ipaddress

"""
Usage in command line:
e.g:
$ python3 tun_if.py /etc/lc/open5gs/smf.yaml
"""

# The tun interfaces configured in Open5GS SMF
internet_tun_ifname = 'ogstun'
ims_tun_ifname = 'ogstun2'

def check_subnet(network):
    # Check that it's a valid subnet and return the IP version 
    try:
       ipaddress.ip_network(network)
       if ":" in network:
          return "IPv6"
       else:
          return "IPv4"
    except ValueError:
       raise ValueError('Value does not represent a valid IPv4/IPv6 range')
    
def execute_bash_cmd(bash_cmd):
    # print('Executing: /bin/bash -c {}.format(bash_cmd))
    return subprocess.run(bash_cmd, stdout=subprocess.PIPE, shell=True)

def setup_tun_if(tun_ifname,
                 ipv4_range,
                 ipv6_range,
                 nat_rule):

    # Get the first IP address in the IP range and netmask prefix length
    first_ipv4_addr = next(ipv4_range.hosts(), None)
    if not first_ipv4_addr:
        raise ValueError('Invalid UE IPv4 range. Only one IP given')
    else:
        first_ipv4_addr = first_ipv4_addr.exploded
    first_ipv6_addr = next(ipv6_range.hosts(), None)
    if not first_ipv6_addr:
        raise ValueError('Invalid UE IPv6 range. Only one IP given')
    else:
        first_ipv6_addr = first_ipv6_addr.exploded

    ipv4_netmask_prefix = ipv4_range.prefixlen
    ipv6_netmask_prefix = ipv6_range.prefixlen

    # Set up the TUN interface, set IP address and set up IPtables
    # if ls /sys/class/net | grep "ogstun" ; then ip link delete ogstun; fi
    execute_bash_cmd('ip tuntap add name ' + tun_ifname + ' mode tun')
    execute_bash_cmd('ip addr add ' + first_ipv4_addr + '/' +
                     str(ipv4_netmask_prefix) + ' dev ' + tun_ifname)
    execute_bash_cmd('ip addr add ' + first_ipv6_addr + '/' +
                     str(ipv6_netmask_prefix) + ' dev ' + tun_ifname)
    execute_bash_cmd('ip link set ' + tun_ifname + ' mtu 1450')
    execute_bash_cmd('ip link set ' + tun_ifname + ' up')
    if nat_rule:
        execute_bash_cmd('if ! iptables-save | grep -- \"-A POSTROUTING -s ' + ipv4_range.with_prefixlen + ' ! -o ' + tun_ifname + ' -j MASQUERADE\" ; then ' +
                         'iptables -t nat -A POSTROUTING -s ' + ipv4_range.with_prefixlen + ' ! -o ' + tun_ifname + ' -j MASQUERADE; fi')
        execute_bash_cmd('if ! ip6tables-save | grep -- \"-A POSTROUTING -s ' + ipv6_range.with_prefixlen + ' ! -o ' + tun_ifname + ' -j MASQUERADE\" ; then ' +
                         'ip6tables -t nat -A POSTROUTING -s ' + ipv6_range.with_prefixlen + ' ! -o ' + tun_ifname + ' -j MASQUERADE; fi')
        execute_bash_cmd('if ! iptables-save | grep -- \"-A INPUT -i ' + tun_ifname + ' -j ACCEPT\" ; then ' +
                         'iptables -A INPUT -i ' + tun_ifname + ' -j ACCEPT; fi')
        execute_bash_cmd('if ! ip6tables-save | grep -- \"-A INPUT -i ' + tun_ifname + ' -j ACCEPT\" ; then ' +
                         'ip6tables -A INPUT -i ' + tun_ifname + ' -j ACCEPT; fi')

@click.command()
@click.argument('filename')
@click.option('--internet',
              default='yes',
              help='Set up the Internet APN ({})'.format(internet_tun_ifname))
@click.option('--ims',
              default='yes',
              help='Set up the IMS APN ({})'.format(ims_tun_ifname))

def start(filename, internet, ims):
    # Load the Open5GS SMF configuration
    with open(filename, 'r') as file:
        config = yaml.safe_load(file)
    # Get the PDN subnets
    for pdn in config['smf']['session']:
       dnn = pdn['dnn']
       subnet = pdn['subnet']
       if dnn == 'internet' and check_subnet(subnet) == 'IPv4':
           UE_IPV4_INTERNET = ipaddress.ip_network(subnet)
       elif dnn == 'internet' and check_subnet(subnet) == 'IPv6':
           UE_IPV6_INTERNET = ipaddress.ip_network(subnet)
       elif dnn == 'ims' and check_subnet(subnet) == 'IPv4':
           UE_IPV4_IMS = ipaddress.ip_network(subnet)
       elif dnn == 'ims' and check_subnet(subnet) == 'IPv6':
           UE_IPV6_IMS = ipaddress.ip_network(subnet)
       else:
           raise ValueError('Unknown DNN')
    # Set up the tun interfaces
    if internet == 'yes':
        print('Setting up Internet tun interface {} with IPv4 subnet {}, IPv6 subnet {} and NAT.'.format(internet_tun_ifname, UE_IPV4_INTERNET, UE_IPV6_INTERNET))
        setup_tun_if(internet_tun_ifname, UE_IPV4_INTERNET, UE_IPV6_INTERNET, True)
    if ims == 'yes':
        print('Setting up IMS tun interface {} with IPv4 subnet {} and IPv6 subnet {} (no NAT).'.format(ims_tun_ifname, UE_IPV4_IMS, UE_IPV6_IMS))
        setup_tun_if(ims_tun_ifname, UE_IPV4_IMS, UE_IPV6_IMS, False)

if __name__ == '__main__':
    start()
