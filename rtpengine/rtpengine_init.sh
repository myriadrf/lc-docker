#!/bin/bash

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

set -x

# Note that this script will attempt to load the rtpengine kernel module and
# set up associated iptables rules. However, if this fails rtpengine will still
# work, albeit with reduced performance and forwarding via userspace.

# Attempt to load the kernel module on the host
if lsmod | grep xt_RTPENGINE || modprobe xt_RTPENGINE; then
	echo "rtpengine kernel module already loaded."
else
	modprobe xt_RTPENGINE
fi

set +e
if [ -e /proc/rtpengine/control ]; then
	echo "del 0" > /proc/rtpengine/control 2>/dev/null
fi

# Freshly add the iptables rules to forward the udp packets to the iptables-extension "RTPEngine":
# Remember iptables table = chains, rules stored in the chains
#
# -N: Create a new chain with the name rtpengine
iptables -N RTPENGINE 2> /dev/null

# -D: Delete the rule for the target "rtpengine" if it exists. -j (target): chain name or extension name
# from the table "filter" (the default without the option '-t')
iptables -D INPUT -j RTPENGINE 2> /dev/null
# Add the rule again so that packets will go to the rtpengine chain after the (filter-INPUT) hook point.
iptables -I INPUT -j RTPENGINE
# Delete and Insert a rule in the rtpengine chain to forward the UDP traffic
iptables -D RTPENGINE -p udp -j RTPENGINE --id "0" 2>/dev/null
iptables -I RTPENGINE -p udp -j RTPENGINE --id "0"
iptables-save > /etc/iptables.rules

# The same for IPv6
ip6tables -N RTPENGINE 2> /dev/null
ip6tables -D INPUT -j RTPENGINE 2> /dev/null
ip6tables -I INPUT -j RTPENGINE
ip6tables -D RTPENGINE -p udp -j RTPENGINE --id "0" 2>/dev/null
ip6tables -I RTPENGINE -p udp -j RTPENGINE --id "0"
ip6tables-save > /etc/ip6tables.rules

# Add a static route for traffic to get back to UEs since there is no NATing
ip r add 192.168.101.0/24 via 172.24.0.22

set -x

# Execute rtpengine
exec /usr/sbin/rtpengine --config-file=/etc/lc/rtpengine/rtpengine.conf