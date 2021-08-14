#!/bin/bash

json_file="config/ec2instances.json"
if [ ! -f $FILE ]; then
  echo "File not exists."
  exit 255
fi

now=$(date '+%H%M')
echo "------------------------------------"
echo "Now :${now}"
echo "------------------------------------"

input_list=`cat ${json_file}`
input_length=`echo ${input_list} | jq .Instances | jq length`

for i in `seq 0 $(expr ${input_length} - 1)`
do
  input_instance=`echo ${input_list} | jq .Instances[${i}]`
  name=`echo ${input_instance} | jq -r .Name`
  start_time=`echo ${input_instance} | jq -r .StartTime`
  end_time=`echo ${input_instance} | jq -r .EndTime`
  echo "インスタンス名: ${name}"

  # 入力が時間形式かどうか確認する
  if [[ ${start_time} =~ ^[0-9]{4}$ && ${end_time} =~ ^[0-9]{4}$ ]]; then
    echo "起動時間：${start_time} - ${end_time}"
  else
    echo "起動時間：指定なしまたは形式不備のため開始・停止を行いません。"
    echo "------------------------------------"
    continue
  fi

  instance_list=`aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" --query "Reservations[].Instances[]"`
  # 取得できた場合
  instance=`echo ${instance_list} | jq ".[0]"`
  instance_id=`echo ${instance} | jq -r ".InstanceId"`
  instance_status=`echo ${instance} | jq -r ".State.Name"`
  echo "現在のステータス: ${instance_status}"

  # 実行中または停止中であるか
  if [ ${instance_status} != "running" -a ${instance_status} != "stopped" ]; then
    echo "running / stopped 以外のステータスのためスキップします。"
    echo "------------------------------------"
    continue
  fi

  # 指定時間に含まれているか
  if [ ${now} -ge ${start_time} -a ${now} -lt ${end_time} ]; then
    if [ ${instance_status} == "stopped" ]; then
      echo "停止中のため開始します"
      aws ec2 start-instances --instance-ids ${instance_id}
    else
      echo "すでに実行中です"
    fi
  else
    if [ ${instance_status} == "running" ]; then
      echo "実行中のため停止します"
      aws ec2 stop-instances --instance-ids ${instance_id}
    else
      echo "すでに停止中です"
    fi
  fi
  echo "------------------------------------"
done
