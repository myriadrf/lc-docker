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

# Sleep until permissions are set
#sleep 10;

# Copy in configuration

cp /mnt/pyhss/config.yaml ./
cp /mnt/pyhss/default_ifc.xml ./
cp /mnt/pyhss/default_sh_user_data.xml ./

# Launch PyHSS component

cd services

if [[ -z "$COMPONENT_NAME" ]]; then
	echo "Error: COMPONENT_NAME environment variable not set"; exit 1;
elif [[ "$COMPONENT_NAME" = api  ]]; then
	echo "Deploying component: '$COMPONENT_NAME'" 
	python3 -u apiService.py --host=$PYHSS_IP --port=8080
elif [[ "$COMPONENT_NAME" = base ]]; then
        echo "Deploying component: '$COMPONENT_NAME'"
        python3 -u diameterService.py &
	    sleep 5
	    python3 -u hssService.py
elif [[ "$COMPONENT_NAME" = diameter ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	python3 -u diameterService.py
elif [[ "$COMPONENT_NAME" = hss ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	python3 -u hssService.py
elif [[ "$COMPONENT_NAME" = geored  ]]; then
	echo "Deploying component: '$COMPONENT_NAME'" 
	python3 -u georedService.py
elif [[ "$COMPONENT_NAME" = log ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	python3 -u logService.py
elif [[ "$COMPONENT_NAME" = metrics ]]; then
	echo "Deploying component: '$COMPONENT_NAME'"
	python3 -u metricService.py
else
	echo "Error: Invalid component name: '$COMPONENT_NAME'"
fi
