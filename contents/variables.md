# Secure Variables Storage

Terraformはソフトウェアの性質上、非常に機密性の高いデータを利用します。例えばAWSにプロビジョニングを実行する際は強い権限を持ったアカウントのキーを使う必要があります。

「初めてのTerraform」の章で変数をセットするには下記の方法があると記述しました。

* `tfvars`というファイルの中で定義する
* `terraform apply -vars=***`という形でCLIの引数で定義する
* `TF_VAR_***`という環境変数で定義する
* Plan中に対話式で入力して定義する

いずれの方法もファイル、OSのコマンド履歴、環境変数などにシークレットが残ってしまう可能性があります。そこでEnterprise版ではHashiCorp Vaultの暗号化エンジンをバックエンドで利用したVariable Storageを簡単に使うことができます。これによって安全に変数を扱うことができます。

Variableのストレージは一つのワークスペースに一つ用意されます。またこの他にもステートファイルなど重要なデータは例外なく暗号化され保存されています。

## 変数のセット

先ほど作成した`tf-handson-workshop`に変更を加えます。`hello-tf`で利用したコードをコピーします。

```shell
cp path/to/hello-tf/main.tf path/to/tf-handson-workshop/main.tf
cp path/to/hello-tf/variables.tf path/to/tf-handson-workshop/variables.tf
```

`hello-tf`では環境変数を使って変数の値をセットしましたが、今回はエンタープライズの機能を利用します。変数のセットはGUIもしくはCLIで設定できます。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-1.png">
</kbd>

`Add variables`をクリックして以下の変数を入力してください。

```
* access_key : 自身のキー : Senstive
* secret_key : 自身のキー : Senstive
* region : ap-northeast-1
* ami : ami-06d9ad3f86032262d
* hello_tf_instance_count : 1
* hello_tf_instance_type : t2.micro
```

<details><summary>GCPの場合はこちら</summary>

```
* gcp_key : JSONファイルコピペ : Senstive
* region : ap-northeast1
* image : ami-06d9ad3f86032262d
* machine_type : f1-micro
* project : PROJECT_NAME
```
</details>

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-2.png">
</kbd>

またこれらの値は[TFC API](https://www.terraform.io/docs/cloud/api/variables.html)でセットすることもできます。

ここまで完了したらコードをコミットしてみます。

```shell
git add .
git commit -m "first commit"
git remote add origin https://github.com/tkaburagi/tf-handson-workshop.git
git push -u origin master
```

## 実行結果の確認

ワークスペースのトップ画面に戻ると新規のコミットに対してプランが走っていることがわかります。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-3.png">
</kbd>

クリックしてプランの詳細を確認し、プランが終わるとApply可能になります。`Confirm`をクリックしApplyを実行ししばらくすると成功するはずです。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-3.png">
</kbd>

AWS CLIで確認します。

```console
$ aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State"
[
    {
        "InstanceId": "i-07bbdb6c0532e1617",
        "State": {
            "Code": 16,
            "Name": "running"
        }
    }
]
```

節約のために環境を綺麗にしておきましょう。DestroyをGUIから実行するためにはTFCのワークスペースの環境変数に設定が必要です。ワークスペースの`Variables`のメニューの`Environment Variables`の項目に以下を入力します。**Terraform Variables**ではないのでご注意ください。

* CONFIRM_DESTROY : 1

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-5.png">
</kbd>

Saveしたらワークスペースのセッテイングから`Destruction and Deletion`を選びます。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-6.png">
</kbd>

`Queue Destroy Plan`を選択し、プランが完了したら`Confirm & Apply`でdestroyを実行してください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-7.png">
</kbd>

Destroyされていることを確認しましょう。

```console
$ aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State"
[
    {
        "InstanceId": "i-07bbdb6c0532e1617",
        "State": {
            "Code": 16,
            "Name": "terminated"
        }
    }
]
```

## ステートファイルの確認

ユーザはTerraformのステートファイルの運用をTFCに任せることができます。TFCはステートファイルのシングルレポジトリとなり、ステートの共有、外部ストレージの作成、外部ストレージへの保存、暗号化やバージョン管理などといった通常必要な作業を実施してくれます。

ワークスペースのメニューから`States`を選択します。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/state-1.png">
</kbd>

複数バージョンのステートがリストされていることがわかります。最新のステートを選択してみましょう。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/state-2.png">
</kbd>

diffが取られ、変更点なども直感的に確認できます。各実行は毎回この最新のステートが取得されるためステートファイルの共有などもシンプルなワークフローとなります。
　
## 参考リンク
* [Data Protection](https://www.terraform.io/docs/enterprise/system-overview/data-security.html)
* [Variables](https://www.terraform.io/docs/cloud/workspaces/variables.html)
* [TFC API Doc](https://www.terraform.io/docs/cloud/api/index.html)