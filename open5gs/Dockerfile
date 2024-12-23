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

FROM ubuntu:jammy

LABEL org.opencontainers.image.title="Open5GS" \
      org.opencontainers.image.description="Open Source 5G Core and LTE EPC" \
      org.opencontainers.image.version="2.7.2LC01" \
      org.opencontainers.image.source="https://github.com/myriadrf/lc-docker" \
      org.opencontainers.image.documentation="https://librecellular.org" \
      org.opencontainers.image.vendor="LibreCellular Project" \
      org.opencontainers.image.authors="andrew@abopen.com"

ENV DEBIAN_FRONTEND=noninteractive

# Install OS updates and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common gpg-agent iproute2 iptables traceroute tcpdump \ 
        iputils-ping python3-setuptools python3-wheel python3-pip 

# Install Open5GS from the PPA
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:open5gs/latest && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        open5gs-smf=2.7.2* open5gs-upf=2.7.2* open5gs-sgwc=2.7.2* \ 
        open5gs-sgwu=2.7.2* open5gs-mme=2.7.2*

# Install tun_if.py PyPi dependencies
RUN pip3 install click ipaddress pyyaml

WORKDIR /open5gs

# Copy scripts
COPY open5gs_init.sh .
COPY tun_if.py .

# Launch
CMD ["/open5gs/open5gs_init.sh"]
