# original_apis_infra


# オンプレミスデプロイグループの登録
オンプレとしての登録(タグも登録)
![オンプレ確認](images/dg/タグ登録.png)
確認
![確認](images/dg/確認.png)


# sourceの登録
保留中になっている
![step1](images/connections/step1.png)
リポジトリを選択
![step2](images/connections/step2.png)
成功していることを確認
![step3](images/connections/step3.png)

## デプロイエージェントの登録
オンプレミスの登録<br>
regionはlightsailのregion
```
aws deploy register-on-premises-instance --instance-name LAMP_PHP_8-1  --iam-user-arn arn:aws:iam::697698772502:user/for_awslightsail --region ap-northeast-1  --profile for_awslightsail

aws deploy add-tags-to-on-premises-instances --instance-names LAMP_PHP_8-1  --tags Key=Name,Value=CodeDeployMyLightsail --region ap-northeast-1 --profile for_awslightsail

aws deploy list-on-premises-instances --region ap-northeast-1 --profile for_awslightsail

```

登録解除
aws deploy deregister-on-premises-instance --instance-name LAMP_PHP_8-1 --profile norio

ログ
tail -1000 /var/log/aws/codedeploy-agent/codedeploy-agent.log

以下の状態になっていればagent側が受付OKにはなっている
```
2025-11-23T13:57:38 INFO  [codedeploy-agent(626040)]: Version file found in /opt/codedeploy-agent/.version with agent version OFFICIAL_1.8.0-17_deb.
2025-11-23T13:58:23 INFO  [codedeploy-agent(626040)]: [Aws::CodeDeployCommand::Client 200 45.335323 0 retries] poll_host_command(host_identifier:"arn:aws:iam::697698772502:user/norio_202407") 
```

codededeploy-agentの停止、開始、確認
```
sudo systemctl stop codedeploy-agent
sudo systemctl start codedeploy-agent
sudo systemctl status codedeploy-agent
● codedeploy-agent.service - LSB: AWS CodeDeploy Host Agent
     Loaded: loaded (/etc/init.d/codedeploy-agent; generated)
     Active: active (running) since Sun 2025-11-23 13:53:00 UTC; 9s ago
       Docs: man:systemd-sysv-generator(8)
    Process: 626032 ExecStart=/etc/init.d/codedeploy-agent start (code=exited, status=0/SUCCESS)
      Tasks: 2 (limit: 510)
     Memory: 56.3M
        CPU: 1.187s
     CGroup: /system.slice/codedeploy-agent.service
             ├─626038 "codedeploy-agent: master 626038"
             └─626040 "codedeploy-agent: InstanceAgent::Plugins::CodeDeployPlugin::CommandPoller of master 626038"

```
またappspec.ymlの登録やディレクトリがないと、
```
The deployment failed because no instances were found for your deployment group. Check your deployment group settings to make sure the tags for your Amazon EC2 instances or Auto Scaling groups correctly identify the instances you want to deploy to, and then try again.
```

https://syuntech.net/aws/aws-codedeploy_error/#google_vignette
codepipelineとawslightsailとprofileのregionをできれば統一すべき！
そうしないとインスタンスが見つからない・・・となってしまう！