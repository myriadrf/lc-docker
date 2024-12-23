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

LABEL org.opencontainers.image.title="srsRAN 4G" \
      org.opencontainers.image.description="Open source 4G software radio suite" \
      org.opencontainers.image.version="23.11LC01" \
      org.opencontainers.image.source="https://github.com/myriadrf/lc-docker" \
      org.opencontainers.image.documentation="https://librecellular.org" \
      org.opencontainers.image.vendor="LibreCellular Project" \
      org.opencontainers.image.authors="andrew@abopen.com"

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install software-properties-common

# Install Lime Suite
RUN add-apt-repository ppa:myriadrf/drivers && \
    apt-get update && apt-get -y install limesuite

# Install srsRAN 4G
RUN add-apt-repository ppa:myriadrf/librecellular && \
    apt-get update && apt-get -y install srsran

WORKDIR /srslte

# Copy init script
COPY srslte_init.sh .

# Launch
CMD ["/srslte/srslte_init.sh"]