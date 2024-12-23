# LibreCellular Docker Container Images

This repository contains the Docker container image sources for the LibreCellular RAN, EPC and IMS stack.

The configurations are based on the [docker_open5gs project](https://github.com/herlesupreeth/docker_open5gs/), with numerous changes.

Issues should be logged to the issue tracker on this repo.

For questions regarding use and general discussion please post to the [MyriadRF forum](https://discourse.myriadrf.org/c/projects/librecellular/39).

## Images

### srsRAN 4G (srslte)

The [LibreCellular fork of srsRAN 4G](https://github.com/myriadrf/srsRAN_4G/), with native support for the Lime Suite API.

For the sake of brevity this is still referred to by its old name (srsLTE) and although, confusingly, _srsRAN 4G_ includes 5G support, this has not been tested with the LibreCellular fork or this image.

### PyHSS

Python Home Subscriber Server implementing Diameter / 3GPP Interfaces.

### Open5GS

Open source implementation for 5G Core and LTE EPC.

Note that the current focus is on EPC support and you should not use this image if you require a 5GC.

### Kamailio IMS

The open source SIP server. 

This image can be configured to act as a P-CSCF, I-CSCF, S-CSCF or SMSC in an LTE IMS.

## Licence

LibreCellular Docker Container Images are published under the BSD 2-Clause License.