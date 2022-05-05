#!/bin/bash

# Load modules on the compute node else there could be a python/r version mismatch


${SPARK_HOME}/sbin/start-master.sh --properties-file /share/Apps/spark/lurc/conf/spark-defaults.conf > ${SPARK_LOG_DIR}/master.out 2>${SPARK_LOG_DIR}/master.err &
#${SPARK_HOME}/sbin/start-master.sh > ${SPARK_LOG_DIR}/master.out 2>${SPARK_LOG_DIR}/master.err &

${SPARK_HOME}/sbin/start-history-server.sh --properties-file /share/Apps/spark/lurc/conf/spark-defaults.conf > ${SPARK_LOG_DIR}/history.out 2>${SPARK_LOG_DIR}/history.err &
#${SPARK_HOME}/sbin/start-history-server.sh > ${SPARK_LOG_DIR}/history.out 2>${SPARK_LOG_DIR}/history.err &

#wait for master to start
sleep 10

for node in $(scontrol show hostname)
do
  ssh -n $node "module load spark; \
     '${SPARK_HOME}'/bin/spark-class org.apache.spark.deploy.worker.Worker spark://'${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}' " \
     > ${SPARK_LOG_DIR}/worker-${node}.out 2>${SPARK_LOG_DIR}/worker-${node}.err & 
  sleep 5
done

sleep 5

export historywebui=$(egrep -i "started at" ${SPARK_LOG_DIR}/history.err | cut -d " " -f 12)
export masterwebui=$(egrep -i "started at" ${SPARK_LOG_DIR}/master.err | cut -d " " -f 12)
export sparkmaster=$(egrep -i "Starting Spark master" ${SPARK_LOG_DIR}/master.err | cut -d " " -f 9)

echo
echo "===================================================================="
echo "SPARK Master        : ${sparkmaster}"
echo "SPARK Master WebUI  : ${masterwebui}"
echo "SPARK History WebUI : ${historywebui}"
for node in $(scontrol show hostname)
do
  sleep 5
  workerwebui=$(egrep WorkerWebUI $SPARK_LOG_DIR/worker-$node.err | cut -d" " -f 12)
  echo "SPARK Worker WebUIs : ${workerwebui}" 
done
echo "===================================================================="


