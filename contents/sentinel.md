# SentinelによるPolicy as Code

Terraformは便利なツールですが、多くのユーザが利用し大規模な運用になるとガバンナンスをきかせユーザの行動を制御することが運用上課題となります。有償版ではHashiCorpが開発する[Sentinel](https://www.hashicorp.com/sentinel)というフレームワークを利用し、ポリシーを定義することができます。

定義できるポリシーは多岐に渡りますが、下記のような一例としてユースケースがあります。

* Terrafrom実行時間の制御
* AZ/Regionの制約
* タグの確認
* CIDRやネットワーク設定の確認
* 特定リソースの利用禁止

## Sentinelコードの作成
それではまずはSentinelを利用するための設定を行います。Sentinelは最低限二つのファイルが必要です。一つは`sentinel.hcl`、もう一つは`<POLICYNAME>.sentinel`です。

```
GitHub上に`sentinel-handson-workshop`という名前のパブリックレポジトリを作成してください。
```

```shell
$ mkdir -p tf-workspace/sentinel-handson-workshop
$ cd tf-workspace/sentinel-handson-workshop
```

以下の二つのファイルを追加します。

* 全クラウド共通のファイル

```shell
$ cat <<EOF > sentinel.hcl
policy "first-policy" {
    enforcement_level = "hard-mandatory"
}
EOF
```

* クラウドごとに変化するファイル

```shell
$ cat <<EOF > first-policy.sentinel
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

<details><summary>GCPの場合はこちら</summary>

```
import "tfplan"

main = rule {
  all tfplan.resources.google_compute_instance as _, instances {
    all instances as _, r {
      (length(r.applied.labels) else 0) > 0
    }
  }
}
```
</details>

<details><summary>Azureの場合はこちら</summary>

```
import "tfplan"

main = rule {
  all tfplan.resources.azurerm_virtual_machine as _, instances {
    all instances as _, r {
      (length(r.applied.tags) else 0) > 0
    }
  }
}
```
</details>


このようになっていればOKです。

```
.
├── sentinel-handson-workshop
│   ├── first-policy.sentinel
│   └── sentinel.hcl
└── tf-handson-workshop
    ├── main.tf
    └── variables.tf
```

`sentinel.hcl`のファイルは実際のポリシーが定義されているコードの設定を行います。`enforcement_level`を定義し、そのポリシーの強制度合いを設定します。

* soft-mandatory
	* ポリシーに引っかかりエラーになった時にそれをオーバーライドして実行を許可するか、拒否するかを選択できるモード
* hard-mandatory
	* ポリシーに引っかかったら必ず実行を拒否するモード
* advisory
	* 実行は許可するが、警告を出すモード

`first-policy.sentinel`のファイルは実際のポリシーコードです。ここの例は全てのインスタンスに対してタグがついているかを確認しています。

それではこれをGitHubにプッシュしてみます。

```shell
$ echo "# sentinel-handson-workshop" >> README.md
$ export GITURL=<YOUR_GIT_REPO_URL>
$ git init
$ git add .
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin ${GITURL}
$ git push -u origin main
```

## TFCの設定
次にTFC側の設定です。トップ画面の一番上のタブから`Settings`を選択し、

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-0.png">
</kbd>

`Policy Sets`を選び`Create Policy Sets`をクリックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-1.png">
</kbd>

以下のように入力してください。名前などは任意で構いません。**workspaceを選んだらADD WORKSPACEを押すのを忘れないでください。**

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
  tags = {
    owner = "me"
    ttl   = "100"
  }
}
```

<details><summary>GCPの場合はこちら</summary>

```
terraform {
}

provider "google" {
  credentials = var.gcp_key
  project     = var.project
  region      = var.region
}

resource "google_compute_instance" "vm_instance" {
  name = "terraform-instance-${count.index}"
  machine_type = var.machine_type
  count = var.hello_tf_instance_count
  zone = "asia-northeast1-a"
  labels = {
    owner = "me",
    ttl   = "100"
  }
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }
}
```
</details>

<details><summary>Azureの場合はこちら</summary>

```hcl
terraform {
}

provider "azurerm" {
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

resource "azurerm_virtual_machine" "main" {
  name                  = "my-vm-${count.index}"
  count = var.hello_tf_instance_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.*.id[count.index]]
  vm_size               = var.vm_size

  os_profile {
    computer_name  = "hostname"
    admin_username = "vmadmin"
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    owner = "me",
    ttl   = "100"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "my-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "my-group"
  location = var.location
}


resource "azurerm_virtual_network" "example" {
  name                = "my-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name   = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "example" {
  name                = "my-nw-interface-${count.index}"
  count = var.hello_tf_instance_count
  location            = var.location
  resource_group_name   = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "payground"
  }
}
```
</details>

```shell
$ git add main.tf
$ git commit -m "added tags"
$ git push
```

再度ワークスペースのRunsの中から最新の実行を選んでください。次はポリシーチェックをクリアし、Applyできるはずです。`confirm & apply`をクリックしてApplyしてみましょう。

Applyが成功したら念の為インタンスにタグが付与されていることも確認しておきましょう。(GCP/Azureの場合はWebブラウザから確認してください。)

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
                "Value": "me",
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

## Sentinel Simulator

Sentinelで都度実際に実行して確認するのではなく`Sentinel Sumilator`を利用してテストを実施するのが普通です。テストにはsentinel cliが必要なので[こちらから](https://docs.hashicorp.com/sentinel/downloads)ダウンロードしてください。

`Apply`と`Test`の二つの機能があります。

### Apply

applyコマンドはSentinelのコードをローカルで実行して試すコマンドです。ポリシーが意図通り動いていることやSyntaxや文法にエラーがないかなどを事前に確認することができます。

Applyにはコンフィグレーションファイルというファイルが必要です。このファイルにはモックデータやテストケースを記述します。

サンプルを一つ作ってみます。

```shell
$ mkdir simulator-sample
$ cd simulator-sample
```

```shell
$ cat <<EOF > sentinel.json
{
    "mock": {
        "time": {
            "hour": 9,
            "minute": 42
        }
    }
}
EOF
```

これがコンフィグレーションファイルとなります。このjsonは[time](https://docs.hashicorp.com/sentinel/imports/time)というSentinelの標準で使える機能をモックし、仮のデータ`9時42分`として入れています。

次にSentinelのコードを作ります。

```shell
$ cat <<EOF > foo.sentinel
import "time"

main = time.hour == 10
EOF
```

ここでは10時かどうかを確認しているためApplyするとエラーになるはずです。Applyして試してみましょう。

```console
$ sentinel apply foo.sentinel
Fail

Execution trace. The information below will show the values of all
the rules evaluated and their intermediate boolean expressions. Note that
some boolean expressions may be missing if short-circuit logic was taken.
```

コードを直して再度試してみます。`main = time.hour == 10` を`main = time.hour == 9`に変更して再度Applyを実行します。

```console
$ sentinel apply foo.sentinel
Pass
```

データのモックには上記のように静的に指定する方法とSentinelのコードで指定する方法があります。関数などJSONで静的にデータをモック出来ないタイプのデータがいくつかあります。ここでは関数を指定する方法を試してみます。

まずは関数を一つ作ってみます。ここでのSentinelはポリシーの定義ではなくあくまでも関数でのモックデータの定義なので`main`は必要ありません。

```shell
$ cat <<EOF > mock-foo.sentinel
bar = func() {                                                                                                                                                           
    return "baz"                                                                                                                                                                
}                                                                                                                                                                               
EOF   
```

次に新しいコンフィグを作ってモックデータに先ほどSentinelで作った関数を指定します。

```shell
$ cat <<EOF > sentinel-2.json
{                                                                                                                                                                        
    "mock": {                                                                                                                                                                   
        "foo": "mock-foo.sentinel"                                                                                                                                              
    }                                                                                                                                                                           
}                                                                                                                            
EOF       
```

最後に新しいポリシーの定義ファイルを作ります。

```shell
$ cat <<EOF > foo-2.sentinel
import "foo"                                                                                                                                                                    
                                                                                                                                                                                
main = foo.bar() == "baz"
EOF
```

モックデータで定義されている`foo`をimportして、関数`bar`を実行し、実行結果が`baz`であるかどうかを判定しています。

```console
$ sentinel apply -config=sentinel-2.json foo-2.sentinel
Pass
```

ApplyするとPassとなるはずです。

### Terraformのデータを利用する

上記の例ではシンプルなデータを使ってSimulatorの機能を試してきました。実際のTerraformの環境ではモックのデータを自分で作るにはかなりの手間がかかります。TFCではSetinel用にワークスペースの最新の構成をモックデータとしてExportする機能が入っています。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/sentinel-5.png">
</kbd>

WorkspacesのRunsから最新の実行結果の`Plan finished`をクリックすると`Downloads Sentinel mocks`というボタンがあるのでこれをクリックしてモックデータをダウンロードし新しいフォルダを作ります。

```shell
$ tar xvfz path/to/run-gvXm387VP1VShKC1-sentinel-mocks.tar.gz
$ mkdir -p simulator-tf-sample/test/foo simulator-tf-sample/testdata
$ touch simulator-tf-sample/sentinel.json simulator-tf-sample/foo.sentinel simulator-tf-sample/test/foo/fail.json simulator-tf-sample/test/foo/pass.json
$ mv path/to/run-gvXm387VP1VShKC1-sentinel-mocks/* simulator-tf-sample/testdata/
$ cd simulator-tf-sample
```

以下のような構造になればOKです。

```console
.
├── foo.sentinel
├── sentinel.json
├── test
│   └── foo
│       ├── fail.json
│       └── pass.json
└── testdata
    ├── mock-tfconfig.sentinel
    ├── mock-tfplan.sentinel
    └── mock-tfstate.sentinel

3 directories, 7 files
```

`testdata/`以下にコピーした3つのファイルにはSentinelで定義されたモックデータが入っています。全てを理解する必要はないので、これが最新のTerraformの状況をシミュレートしているとだけ押さえておけばとりあえず大丈夫です。

sentinel.jsonを以下のように記述してください。

```json
{
  "mock": {
    "tfconfig": "testdata/mock-tfconfig.sentinel",
    "tfplan": "testdata/mock-tfplan.sentinel",
    "tfstate": "testdata/mock-tfstate.sentinel"
  }
}
```

ダウンロードした環境をシミュレートするSentinelファイルをモックデータとして指定しています。実際のポリシーコードではこの`tfconfig`, `tfplan`,`tfstate`をimportしてポリシーを定義しローカルで実行します。

一番最初に試したタグの有無をチェックするポリシーを使って試してみたいと思います。`foo.sentinel`を以下のように編集します。

```sentinel
import "tfplan"

main = rule {
  all tfplan.resources.aws_instance as _, instances {
    all instances as _, r {
      (length(r.applied.tags) else 0) > 0
    }
  }
}
```

<details><summary>GCPの場合はこちら</summary>

```
import "tfplan"

main = rule {
  all tfplan.resources.google_compute_instance as _, instances {
    all instances as _, r {
      (length(r.applied.labels) else 0) > 0
    }
  }
}
```
</details>

<details><summary>Azureの場合はこちら</summary>

```
import "tfplan"

main = rule {
  all tfplan.resources.azurerm_virtual_machine as _, instances {
    all instances as _, r {
      (length(r.applied.tags) else 0) > 0
    }
  }
}
```
</details>


`testdata/mock-tfplan.sentinel`を確認してみましょう。

```console
$ grep -A 4 -n tags testdata/mock-tfplan.sentinel
  "tags": {
24-               "owner": "me",
25-               "ttl":   "100",
26-             },
27-             "timeouts":         null,
--
208:              "tags.%": {
209-                "computed": false,
210-                "new":      "2",
211-                "old":      "",
212-              },
--
213:              "tags.owner": {
214-                "computed": false,
215-                "new":      "me",
216-                "old":      "",
217-              },
--
218:              "tags.ttl": {
219-                "computed": false,
220-                "new":      "100",
221-                "old":      "",
222-              },
--
243:              "volume_tags.%": {
244-                "computed": true,
245-                "new":      "",
246-                "old":      "",
247-              },
```

タグがついたデータが入っておりテストが通るはずです。

```console
$ sentinel apply foo.sentinel
Pass
```

最後にポリシーを編集し挙動を確認してみましょう。特定のタグが付与されているインスタンスのみ許可するようにします。`foo.sentinel`を以下のように変更します。

```sentinel
import "tfplan"

mandatory_tags = [
  "ttl", 
  "owner",
]

instance_tags = rule {
    all tfplan.resources.aws_instance as _, instances {
      all instances as index, r {
            all mandatory_tags as t {
                r.applied.tags contains t
            }
        }
    }
}

main = rule {
    (instance_tags) else true
}
```

<details><summary>GCPの場合はこちら</summary>

```
import "tfplan"

mandatory_labels = [
  "ttl", 
  "owner",
]

main = rule {
    all tfplan.resources.google_compute_instance as _, instances {
      all instances as _, r {
            all mandatory_labels as t {
                r.applied.labels contains t
            }
        }
    }
}
```
</details>

<details><summary>Azureの場合はこちら</summary>

```
import "tfplan"

mandatory_labels = [
  "ttl", 
  "owner",
]

main = rule {
    all tfplan.resources.azurerm_virtual_machine as _, instances {
      all instances as _, r {
            all mandatory_labels as t {
                r.applied.tags contains t
            }
        }
    }
}
```
</details>

```console
$ sentinel apply foo.sentinel
Pass
```

次に`foo.sentinel`の

```
mandatory_tags = [
  "ttl", 
  "owner",
]
```

を

```
mandatory_tags = [
  "ttl", 
  "owner",
  "env",
]
```

と変更してください。

ポリシーを試してみます。

```console
$ sentinel apply foo.sentinel
Fail

Execution trace. The information below will show the values of all
the rules evaluated and their intermediate boolean expressions. Note that
some boolean expressions may be missing if short-circuit logic was taken.

FALSE - foo.sentinel:19:1 - Rule "main"
  FALSE - foo.sentinel:10:5 - all tfplan.resources.aws_instance as _, instances {
  all instances as index, r {
    all mandatory_tags as t {
      r.applied.tags contains t
    }
  }
}
```

モックデータのインスタンスには`env`のタグはついていないので、Failとなりポリシーが意図通りに動作していることがわかります。

## 参考リンク
* [Sentinel](https://www.hashicorp.com/sentinel)
* [Sentinel Docs](https://docs.hashicorp.com/sentinel/)
* [Sentinel Terraform](https://www.terraform.io/docs/cloud/sentinel/index.html)
* [Sentinel Language](https://docs.hashicorp.com/sentinel/language/)
* [Mocking Terraform Data](https://www.terraform.io/docs/cloud/sentinel/mock.html)
* [Sample Policies](https://github.com/hashicorp/terraform-guides/tree/master/governance)
* [Sample Policies](https://www.terraform.io/docs/cloud/sentinel/examples.html)
