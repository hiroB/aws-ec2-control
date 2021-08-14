#!/bin/bash

##############################
# -f: ファイル名
# -c: インスタンス制御フラグ
##############################
while getopts f:c OPT
do
  case $OPT in
    "f" ) file_name="$OPTARG" ;;
    "c" ) control_flag="true" ;;
  esac
done

json_file="${file_name}"
if [ ! -f $FILE ]; then
  echo "File not found."
  exit 255
fi

. ./instance_control.sh

now=$(date '+%H%M')
input_list=`cat ${json_file}`
input_length=`echo ${input_list} | jq .Instances | jq length`

for i in `seq 0 $(expr ${input_length} - 1)`
do
  input_instance=`echo ${input_list} | jq .Instances[${i}]`
  name=`echo ${input_instance} | jq -r .Name`
  start_time=`echo ${input_instance} | jq -r .StartTime`
  end_time=`echo ${input_instance} | jq -r .EndTime`

  instance_list=`aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" --query "Reservations[].Instances[]"`
  if [ $? != 0 ]; then
    echo "Can't get instance information"
    exit 255
  fi

  instance_length=`echo ${instance_list} | jq length`
  if [ ${instance_length} == 0 ]; then
    echo "${name} は見つかりませんでした。"
  fi

  for j in `seq 0 $(expr ${instance_length} - 1)`
  do
    # 取得できた場合
    instance=`echo ${instance_list} | jq ".[${j}]"`
    instance_id=`echo ${instance} | jq -r ".InstanceId"`
    instance_status=`echo ${instance} | jq -r ".State.Name"`
    echo "${name} : ${instance_status}"
    if [[ -n ${control_flag} && ${control_flag} == "true" ]]; then
      instance_control ${instance_id} ${instance_status} ${now} ${start_time} ${end_time}
    fi
  done
done
