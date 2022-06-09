#!/bin/bash
helpFunction()
{
   echo ""
   echo "Usage: $0 -a kafka-bin-dir -b kafka-topic -c kafka_broker:port"
   echo -e "\t-a Kafka bin directory"
   echo -e "\t-b Kafka topic to read"
   echo -e "\t-c Kafka broker and port"
   #echo -e "\t-d Folder where to download CSV"
   echo ""
   exit 1 # Exit script after printing help
}

kafka_bin_directory=$1
kafka_topic=$2
kafka_broker=$3
metrics_date=`date +"%m-%d-%y"`

# Print helpFunction in case parameters are empty
if [ -z "$kafka_bin_directory" ] || [ -z "$kafka_topic" ] || [ -z "$kafka_broker" ]
then
   helpFunction
fi

timeout 10s bash $kafka_bin_directory/kafka-console-consumer.sh --bootstrap-server $kafka_broker --topic $kafka_topic --from-beginning | jq '.data | select(.target.sampler=="processes")' | jq '{sampleTime: .sampleTime, percentCPU: .row.percentCPU, residentSetSize: .row.residentSetSize, percentMemory: .row.percentMemory, virtualMemory: .row.virtualMemory}' | jq -r '. | [.sampleTime, .percentCPU, .residentSetSize, .percentMemory, .virtualMemory] | @csv' >> "fkm-metrics-$metrics_date.csv"
timeout 10s bash $kafka_bin_directory/kafka-console-consumer.sh --bootstrap-server $kafka_broker --topic $kafka_topic --from-beginning | jq '.data | select(.target.sampler=="toolkit")' | jq -r '. | {sampleTime: .sampleTime, messages: .row."FKM Lines"} | [.sampleTime, .messages] | @csv' >> "toolkit-metrics-$metrics_date.csv"


