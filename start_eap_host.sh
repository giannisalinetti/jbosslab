#!/bin/bash
# JB248 EAP 6.3 course startup scripts for domain labs.

if [ $# -eq 0 ]; then
  echo "Error: Missing host argument"
  exit 1
fi

if [ $1 == "-h" ] || [ $1 == "--help" ]; then
  echo "Usage: $(basename $0) HOST"
  exit 0
fi

# Test Host argument.
DOMAINHOST=$1
if [ $DOMAINHOST == "master" ]; then
  HOSTFILE="host-master.xml"
  MACHINE="machine1"
else
  CONTROLLER=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | sed 's/\/24//')
  if [ $DOMAINHOST == "host2" ]; then
    HOSTFILE="host-slave.xml"
    MACHINE="machine2"
  elif [ $DOMAINHOST == "host3" ]; then
    HOSTFILE="host-slave.xml"
    MACHINE="machine3"
  fi
fi

# Define base config dir
BASE=/home/student/JB248/opt

if [ ! -d ${BASE} ]; then
  echo "Error: ${BASE} not found"
  exit 1
fi

# Test if log direcotory exists, creates a new one if not.
# Old log files will be overwritten in this relaase
LOGS=/home/student/jboss_logs
LOGFILE=${DOMAINHOST}.log

if [ ! -d ${LOGS} ]; then
  mkdir -p ${LOGS}
  if [ $? -ne 0 ]; then
    echo "Error: Unable to create log directory"
    exit 1
  fi
fi

# Start EAP Host instances
if [ ${DOMAINHOST} == "master" ]; then
  echo "Starting Domain Controller ${DOMAINHOST} installed in ${BASE}/${MACHINE}"
  ${EAP_HOME}/bin/domain.sh --host-config=${HOSTFILE} -Djboss.domain.base.dir=${BASE}/${MACHINE}/domain &> ${LOGS}/${LOGFILE}
elif [ ${DOMAINHOST} == "host2" ]; then
  echo "Starting Host Controller ${DOMAINHOST} installed in ${BASE}/${MACHINE}"
  ${EAP_HOME}/bin/domain.sh --host-config=${HOSTFILE} -Djboss.domain.base.dir=${BASE}/${MACHINE}/domain -Djboss.domain.master.address=${CONTROLLER} &> ${LOGS}/${LOGFILE}
elif [ ${DOMAINHOST} == "host3" ]; then
  echo "Starting Host Controller ${DOMAINHOST} installed in ${BASE}/${MACHINE}"
  ${EAP_HOME}/bin/domain.sh --host-config=${HOSTFILE} -Djboss.domain.base.dir=${BASE}/${MACHINE}/domain -Djboss.domain.master.address=${CONTROLLER} &> ${LOGS}/${LOGFILE}
fi

exit 0
