#!/bin/bash


${SPARK_HOME}/sbin/stop-history-server.sh
${SPARK_HOME}/sbin/stop-master.sh

for node in $(scontrol show hostname)
do
  ssh -n $node 'pkill -9 java; rm -rf /tmp/work /tmp/spark-events'
done



echo "Done running Apache SPARK"


