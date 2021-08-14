# aws-ec2-control

## やること

1. JSONを読み込む
2. JSONのInstanceごとにループ
3. 現在時間によって稼働時間か停止時間かを判定
4. InstanceIdをもとにステータスを取得
5. runningかつ停止時間であれば停止
6. stoppedかつ稼働時間であれば開始
7. 上記以外のステータスでは何もしない
