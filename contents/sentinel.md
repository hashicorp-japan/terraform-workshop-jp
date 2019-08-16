# SetinelによるPolicy as Code

Terraformは便利なツールですが、多くのユーザが利用し大規模な運用になるとガバンナンスをきかせユーザの行動を制御することが運用上課題となります。有償版ではHashiCorpが開発する[Sentinel](https://www.hashicorp.com/sentinel)というフレームワークを利用し、ポリシーを定義することができます。

定義できるポリシーは多岐に渡りますが、下記のような一例としてユースケースがあります。

* Terrafrom実行時間の制御
* AZ/Regionの制約
* タグの確認
* CIDRやネットワーク設定の確認
* 特定リソースの利用禁止

## Sentinelコードの作成
それではまずはSentinelを利用するための設定を行います。

GitHub上に`sentinel-handson-workshop`という名前のパブリックレポジトリを作成してください。

```shell
mkdir -p tf-workspace/sentinel-handson-workshop
cd path/to/tf-workspace/sentinel-handson-workshop
```

以下の二つのファイルを追加します。

```shell
cat <<EOF > sentinel.hcl
policy "first-policy" {
    enforcement_level = "hard-mandatory"
}
EOF
```

```shell
cat <<EOF > first-policy.sentinel
import "tfplan"

main = rule {
  all tfplan.resources.aws_instance as _, instances {
    all instances as _, r {
      (length(r.applied.tags) else 0) > 0
    }
  }
}
EOF
```

```shell
echo "# sentinel-handson-workshop" >> README.md
git init
git add .
git commit -m "first commit"
git remote add origin https://github.com/tkaburagi/sentinel-handson-workshop.git
git push -u origin master
```

Sentinelは最低限二つのファイルが必要です。一つは`sentinel.hcl`、もう一つは`<POLICYNAME>.sentinel`です。

```console
$ tree .
.
├── first-policy.sentinel
└── sentinel.hcl

0 directories, 2 files
```

`sentinel.hcl`のファイルは実際のポリシーが定義されているコードの設定を行います。`enforcement_level`を定義し、そのポリシーの強制度合いを設定します。

* soft-mandatory
	* ポリシーに引っかかりエラーになった時にそれをオーバーライドして実行を許可するか、拒否するかを選択できるモード
* hard-mandatory
	* ポリシーに引っかかったら必ず実行を拒否するモード
* advisory
	* 実行は許可するが、警告を出すモード

`first-policy.sentinel`のファイルは実際のポリシーコードです。ここの例は全てのインスタンスに対してタグがついているかを確認しています。

## TFCの設定
次にTFC側の設定です。トップ画面の一番上のタブから`Settings`を選択し、

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-0.png">
</kbd>

`Policy Sets`を選び`Create Policy Sets`をクリックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-1.png">
</kbd>

以下のように入力してください。名前などは任意で構いません。**workspaceを選んだらADD WORKSPACEを押すのを忘れないですください。**

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-2.png">
</kbd>

## ポリシーを試してみる

それでは実行してみましょう。ワークスペースの`Queue Plan`を選択し、Runをキックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-3.png">
</kbd>

前回と違いPolicy Checkのワークフローが追加されていることがわかります。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-4.png">
</kbd>

程なくするとポリシーチェックが開始されエラーになるでしょう。

次にコードを修正し、再度コミットしてみます。`path/to/tf-handson-workshop/main.tf`のコードを以下のように修正してください。

```hcl
terraform {
  required_version = " 0.12.6"
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
  tags = map(
  "owner", "Kabu",
  "ttl", "100"
  )
}
```

```shell
git add main.tf
git commit -m "added tags"
git push
```

再度ワークスペースのRunsの中から最新の実行を選んでください。次はポリシーチェックをクリアし、Applyできるはずです。`confirm & apply`をクリックしてApplyしてみましょう。

Applyが成功したら念の為インタンスにタグが付与されていることも確認しておきましょう。

```console
$ aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State,Tags:Tags}"
[
    {
        "InstanceId": "i-0561854e3727d3704",
        "State": {
            "Code": 16,
            "Name": "running"
        },
        "Tags": [
            {
                "Value": "Kabu",
                "Key": "owner"
            },
            {
                "Value": "100",
                "Key": "ttl"
            }
        ]
    }
]
```

これで最初のSentinelは終了です。ちなみにタグは有無だけではなく特定のタグがない場合を弾くなど、さらに細かく設定することもできます。





## 参考リンク
* [Sentinel](https://www.hashicorp.com/sentinel)
* [Sentinel Terraform](https://www.terraform.io/docs/cloud/sentinel/index.html)