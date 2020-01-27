# HashiCorp Terraform Enterprise Workshop

[Terraform](https://www.terraform.io/)はHashiCorpが中心に開発をするOSSのプロビジョニングツールです。このレイヤではほぼ業界標準のソフトウェアと位置付けられており、国内外のコミュニティなども非常に活発です。

Terraformはインフラのプロビジョニングツールというイメージが強いですが、現在150以上のプロバイダに対応しており、幅広いレイヤでの利用が可能です。

OSS版ではすでに多くの情報が日本語でも調べることが可能なため、本ワークショップはエンタープライズ機能に特化した内容にしています。**Terraformのコアの機能を学習する内容ではないのでご注意ください。**

## Pre-requisite

* 環境
	* macOS or Linux

* ソフトウェア
	* Terraform
	* jq,watch,curl
	* git cli
	* aws / gcloud

* アカウント
	* GitHub
	* Terraform Cloud
	* AWS / GCP

## 資料

* [Terraform Enterprise Overview](https://docs.google.com/presentation/d/1Ovdee0FIrJ_h66B5DToQNYKWJ9XRbudS0RCk4d_x1Eg/edit?usp=sharing)

## アジェンダ
* [初めてのTerraform](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/hello-terraform.md)
* [Terraform cloudによるRemote state管理](./contents/tfc-remote-state.md)
* VCS連携 ([GitHub](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/vcs.md), [Azure DevOps](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/vcs-azure.md))
* [Secure Variable Storage](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/variables.md)
* [Enterprise機能1: RBAC](./contents/teams.md)
* [Enterprise機能2: Policy as Code](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/sentinel.md)
* [Enterprise機能3: Private Module Registry](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/module.md)
* [Enterprise機能4: Terraform Enterprise API](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/tf-api.md)
* [Enterprise機能5: Notifications](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/notifications.md)
* CLI Drive Run
* API Drive Run
* Terraform Enterpriseのインストール
