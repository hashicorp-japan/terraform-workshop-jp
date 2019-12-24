# Secure Variables Storage

Terraformはソフトウェアの性質上、非常に機密性の高いデータを利用します。例えばAWSにプロビジョニングを実行する際は強い権限を持ったアカウントのキーを使う必要があります。

「初めてのTerraform」の章で変数をセットするには下記の方法があると記述しました。

* `tfvars`というファイルの中で定義する
* `terraform apply -vars=***`という形でCLIの引数で定義する
* `TF_VAR_***`という環境変数で定義する
* Plan中に対話式で入力して定義する

いずれの方法もファイル、OSのコマンド履歴、環境変数などにシークレットが残ってしまう可能性があります。そこでEnterprise版ではHashiCorp Vaultの暗号化エンジンをバックエンドで利用したVariable Storageを簡単に使うことができます。これによって安全に変数を扱うことができます。

Variableのストレージは一つのワークスペースに一つ用意されます。またこの他にもステートファイルなど重要なデータは例外なく暗号化され保存されています。

Terraform Enterpriseには二種類に変数がサポートされています。`Terraform Variables`と`Environment Variables`です。

`Terraform Variables`はTerrafromで扱う変数です。ここでセットされた値は`terraform.tfvars`として扱われます。そのため連携するVCSにもし`terraform.tfvars`がある場合はオーバーライドされます。

`Environment Variables`はLinuxのWorker(Terraform Runなどを行うコンポーネント)上にセットされる値です。ここでセットされた値がexportコマンドよって実行前に環境変数としてセットされます。`Environment Variables`の中にはTFE上で特別な意味を持つものが存在します。

* CONFIRM_DESTROY: `Destroy`を許容するかどうか。デフォルトでは無効です。
* TFE_PARALLELISM: 処理高速化のための並列実行のオプションです。デフォルトは10です。


## 変数のセット

先ほど作成した`tf-handson-workshop`に変更を加えます。

```shell
$ cd path/to/tf-workspace/tf-handson-workshop
```

以下の二つのファイルを作成してください。


```shell
$ cat <<EOF > main.tf

terraform {
  required_version = "~> 0.12"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_instance" "hello-tf-instance" {
  ami = var.ami
  count = var.hello_tf_instance_count
  instance_type = var.hello_tf_instance_type
}

EOF
```

```shell 
$ cat << EOF > variables.tf

variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "ami" {}
variable "hello_tf_instance_count" {
    default = 2
}
variable "hello_tf_instance_type" {
    default = "t2.micro"
}

EOF
```

このようになっていればOKです。

```
.
└── tf-handson-workshop
    ├── main.tf
    └── variables.tf
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
* image : debian-cloud/debian-9
* machine_type : f1-micro
* project : PROJECT_NAME
* hello_tf_instance_count : 1
```
</details>

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/var-2.png">
</kbd>

またこれらの値は[TFC API](https://www.terraform.io/docs/cloud/api/variables.html)でセットすることもできます。

ここまで完了したらコードをコミットしてみます。

```shell
$ git add .
$ git commit -m "second commit"
$ git push -u origin master
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
$ aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State}"
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
$ aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State}"
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
* [Terraform VariablesとEnviron Variables](https://www.terraform.io/docs/cloud/workspaces/variables.html#terraform-variables)
