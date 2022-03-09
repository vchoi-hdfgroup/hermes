#!/bin/bash
spack load ior+hermes+hdf5

ls $HOME
ls $HOME/work
ls $HOME/work/hermes
ls $HOME/work/hermes/hermes

HERMES_CONF_PATH=$HOME/work/hermes/hermes/test/data/hermes.conf
HERMES_INSTALL_DIR=$HOME/work/hermes/hermes/install
CHECKPOINT_FILE=checkpoint.tmp
mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3
mpirun -n 2 -ppn 1 \
   -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
   -genv HERMES_CONF ${HERMES_CONF_PATH} \
   -genv HERMES_CLIENT 1 \
   -genv ADAPTER_MODE SCRATCH \
   -genv HERMES_STOP_DAEMON 0 \
   ior -a=MPIIO -w -k -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV
sleep 10
mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3
mpirun -n 2 -ppn 1 \
    -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
    -genv HERMES_CONF ${HERMES_CONF_PATH} \
    -genv HERMES_CLIENT 1 \
    -genv ADAPTER_MODE SCRATCH \
   ior -a=MPIIO -r -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -O summaryFormat=CSV
rm *.hermes
sleep 3
mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3
mpirun -n 2 -ppn 1 \
   -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
   -genv HERMES_CLIENT 1 \
   -genv ADAPTER_MODE SCRATCH \
  -genv HERMES_STOP_DAEMON 0 \
   ior -a=HDF5 -w -k -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -Y
sleep 10
mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3
mpirun -n 2 -ppn 1 \
     -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
     -genv HERMES_CONF ${HERMES_CONF_PATH} \
     -genv HERMES_CLIENT 1 \
     -genv ADAPTER_MODE SCRATCH \
    ior -a=HDF5 -r -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -O summaryFormat=CSV
rm *.hermes
rm checkpoint.tmp*
rm testFile
