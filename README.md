# aws-ec2-control

## やること

1. JSONを読み込む
2. JSONのInstanceごとにループ
3. 現在時間によって稼働時間か停止時間かを判定
4. InstanceIdをもとにステータスを取得
5. runningかつ停止時間であれば停止
6. stoppedかつ稼働時間であれば開始
7. 上記以外のステータスでは何もしない

##  最低限必要なポリシー

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Effect": "Allow"
        }
    ]
}
```
