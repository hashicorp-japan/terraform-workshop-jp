# HashiCorp Terraform Enterprise Workshop

[Terraform](https://www.terraform.io/) は HashiCorp が中心に開発をする OSS のプロビジョニングツールです。このレイヤではほぼ業界標準のソフトウェアと位置付けられており、国内外のコミュニティなども非常に活発です。

Terraform はインフラのプロビジョニングツールというイメージが強いですが、現在 150 以上のプロバイダに対応しており、幅広いレイヤでの利用が可能です。

OSS 版ではすでに多くの情報が日本語でも調べることが可能なため、本ワークショップはエンタープライズ機能に特化した内容にしています。**Terraform のコアの機能を学習する内容ではないのでご注意ください。**

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
* [初めての Terraform](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/hello-terraform.md)
* [Terraform Cloud によるリモートステート管理](./contents/tfc-remote-state.md)
* VCS 連携 ([GitHub](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/vcs.md), [Azure DevOps](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/vcs-azure.md))
* [Secure Variable Storage](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/variables.md)
* [Enterprise 機能 1: RBAC](./contents/teams.md)
* [Enterprise 機能 2: Policy as Code](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/sentinel.md)
* [Enterprise 機能 3: Private Module Registry](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/module.md)
* [Enterprise 機能 4: Terraform Enterprise API](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/tf-api.md)
* [Enterprise 機能 5: Notifications](https://github.com/hashicorp-japan/terraform-workshop/blob/master/contents/notifications.md)
* CLI Drive Run
* [API Drive Run](./contents/api-driven-run.md)
* Terraform Enterprise のインストール
