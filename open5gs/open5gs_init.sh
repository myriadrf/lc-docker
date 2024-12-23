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

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" =~ ^(smf-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
    /usr/bin/open5gs-smfd -c /etc/lc/open5gs/smf.yaml
elif [[ "$COMPONENT_NAME" =~ ^(upf-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
        /usr/bin/python3 tun_if.py /etc/lc/open5gs/smf.yaml && \
        /usr/bin/open5gs-upfd -c /etc/lc/open5gs/upf.yaml
elif [[ "$COMPONENT_NAME" =~ ^(sgwc-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
    /usr/bin/open5gs-sgwcd -c /etc/lc/open5gs/sgwc.yaml
elif [[ "$COMPONENT_NAME" =~ ^(sgwu-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
    /usr/bin/open5gs-sgwud -c /etc/lc/open5gs/sgwu.yaml
elif [[ "$COMPONENT_NAME" =~ ^(mme-[[:digit:]]+$) ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	/usr/bin/open5gs-mmed -c /etc/lc/open5gs/mme.yaml
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi

