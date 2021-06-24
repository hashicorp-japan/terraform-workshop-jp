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

* `CONFIRM_DESTROY`: `Destroy`を許容するかどうか。デフォルトでは無効です。
* `TFE_PARALLELISM`: 処理高速化のための並列実行のオプション。デフォルトは10です。


## 変数のセット

先ほど作成した`tf-handson-workshop`に変更を加えます。

```shell
$ cd path/to/tf-workspace/tf-handson-workshop
```

以下の二つのファイルを作成してください。`main.tf`, `variables.tf` というファイル名です。


```shell
$ cat <<EOF > main.tf

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

<details><summary>GCPの場合はこちら</summary>

```hcl
terraform {
}

provider "google" {
    credentials = var.gcp_key
    project     = var.project
    region      = var.region
}

resource "google_compute_instance" "vm_instance" {
    name = "terraform-instance-${count.index}-<YOURNAME>"
    count = var.hello_tf_instance_count
    machine_type = var.machine_type
    zone = "asia-northeast1-a"
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
```hcl
variable "gcp_key" {}
variable "machine_type" {}
variable "hello_tf_instance_count" {
    default = 1
}
variable "region" {
    default = "asia-northeast1"
}
variable "project" {}
variable "image" {}
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
  features {}
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
```hcl
variable "vm_size" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "admin_password" {}
variable "hello_tf_instance_count" {
    default = 1
}
```
</details>
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

<details><summary>Azureの場合はこちら</summary>

```
* client_id : ******* : Senstive
* client_secret : ******* : Senstive
* tenant_id : ******* : Senstive
* subscription_id : ******* : Senstive
* location : East Asia
* admin_password : Password1234!
* hello_tf_instance_count : 1
* vm_size : Standard_DS1_v2
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
$ git push -u origin main
```

## 実行結果の確認

ワークスペースのトップ画面に戻り`Runs`のタブを見ると新規のコミットに対してプランが走っていることがわかります。

<kbd>
  <img src="https://github.com/hashicorp-japan/terraform-workshop-jp/blob/master/assets/run-new-ui.png">
</kbd>

クリックしてプランの詳細を確認し、プランが終わるとApply可能になります。`Confirm`をクリックしApplyを実行ししばらくすると成功するはずです。

AWS CLIで確認します。(GCP/Azureの場合はWebブラウザから確認してください。)

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

Destroyされていることを確認しましょう。(GCP/Azureの場合はWebブラウザから確認してください。)

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
