# Notificationsを利用してSlackと連携する

ここではTerraform EnterpriseのNotificationsの機能を利用してSlackと連携しTerraform Enterpriseのイベント通知を受信する方法を試してみます。

## Slackの設定

このハンズオンを完了させるにはSlackワークスペースの`Custom Integration`の編集のできる権限が必要です。

[こちら](https://hashicorp-apac.slack.com/apps/manage/custom-integrations)にアクセスして、`Incoming WebHook`の設定を行います。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-1.png">
</kbd>

`Add to Slack`をクリックして、次の画面に進みます。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-2.png">
</kbd>

`Post to Channel`のプルダウンで通知をしたいチャネルやダイレクトメッセージ先を選択しましょう。　

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-3.png">
</kbd>

`Add Incoming WebHook Integaraion`をクリックするとWebHookの設定画面になります。ここで表示される`WebHook URL`をメモしておきます。


**このURLはSlackのトークンも含まれるので絶対にGitHubのレポジトリ等にアップロードしてはいけません。**

## Terraform Enterpriseの設定

あとはこのURLをTerraform Entpriseのワークスペースに設定するだけです。

TFCのブラウザの`Workspaces` -> `handson-workshop` -> `Settings` -> `Notifications` -> `Create a Notification`と進んでください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-4.png">
</kbd>

GeneralなWebHookとSlackが選択できます。Microsoft TeamsやMattermostなどSlack以外のWebHookでの通知に対応しているツールと連携する際はWebHookを選択します。

ここではSlackを選択し

* `Name`: `My Notification`
* `WebHook URL`: 先ほどコピーしたもの
* `Triggers`: `All events`

を選択し`Create a Notification`をクリックします。

完了画面で`Send a Test`をクリックし、Slackに通知が来ることを確認してください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-5.png">
</kbd>

## 実際にプロビジョニングを試す

最後に実際のプロビジョニングでどのようなメッセージが来るかを確認してみましょう。`handson-workshop`のメニューで以下のように`Queue Plan`をして下さい。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-6.png">
</kbd>

`Run`の内容を確認すると、プロビジョニングのワークフローが開始され、都度Slackに通知が来るでしょう。


以下のように通知が来ていれば成功です。
<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/notifications-7.png">
</kbd>

簡単ですが、Terrafrom Enterpriseの通知機能を試してみました。

## 参考リンク
* [Run Notifications](https://www.terraform.io/docs/cloud/workspaces/notifications.html)