#!/bin/bash
HERMES_CONF_PATH=$HOME/src/hermes/test/data/hermes.conf
HERMES_INSTALL_DIR=$HOME/install
CHECKPOINT_FILE=checkpoint.tmp
mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3
mpirun -n 1 -ppn 1 \
  -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  -genv HERMES_CLIENT 1 \
  -genv ADAPTER_MODE SCRATCH \
  -genv HERMES_STOP_DAEMON 0 \
  ior -a=MPIIO -w -k -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV
# mpirun -n 1 -ppn 1 \
#    -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
#    -genv HERMES_CONF ${HERMES_CONF_PATH} \
#    -genv HERMES_CLIENT 1 \
#    -genv ADAPTER_MODE SCRATCH \
#   ior -a=MPIIO -r -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -O summaryFormat=CSV
