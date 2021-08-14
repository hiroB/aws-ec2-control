#!/bin/bash

##############################
# 引数1: インスタンスID
# 引数2: インスタンスステータス
##############################
start_instance () {
  if [ $# != 2 ]; then
    echo "パラメータエラー"
    exit 255
  fi
  if [ $2 == "stopped" ]; then
    echo "停止中のため開始します"
    aws ec2 start-instances --instance-ids $1
  elif [ $2 == "running" ]; then
    echo "すでに実行中です"
  else
    echo "running / stopped 以外のステータスのためスキップします。"
  fi
}

##############################
# 引数1: インスタンスID
# 引数2: インスタンスステータス
##############################
stop_instance () {
  if [ $# != 2 ]; then
    echo "パラメータエラー"
    exit 255
  fi
  if [ $2 == "running" ]; then
    echo "実行中のため停止します"
    aws ec2 stop-instances --instance-ids $1
  elif [ $2 == "stopped" ]; then
    echo "すでに停止中です"
  else
    echo "running / stopped 以外のステータスのためスキップします。"
  fi
}

##############################
# 引数1: インスタンスID
# 引数2: インスタンスステータス
# 引数3: 現在の時間
# 引数4: 開始時間
# 引数5: 終了時間
##############################
instance_control () {
  if [ $# != 5 ]; then
    echo "パラメータエラー"
    exit 255
  fi

  # 時間形式チェック
  if [[ $4 == "-" || $5 == "-" ]]; then
    stop_instance $1 $2
  elif [[ $3 =~ ^[0-9]{4}$ && $4 =~ ^[0-9]{4}$ && $5 =~ ^[0-9]{4}$ ]]; then
    if [ $3 -ge $4 -a $3 -le $5 ]; then
      start_instance $1 $2
    else
      stop_instance $1 $2
    fi
  else
    echo "時間が形式不備のためスキップします。"
  fi
  echo "------------------------------------"
}
