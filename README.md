# HashiCorp Terraform Enterprise Workshop

[Terraform](https://www.terraform.io/) は HashiCorp が中心に開発をする OSS のプロビジョニングツールです。このレイヤではほぼ業界標準のソフトウェアと位置付けられており、国内外のコミュニティなども非常に活発です。

Terraform はインフラのプロビジョニングツールというイメージが強いですが、現在 150 以上のプロバイダに対応しており、幅広いレイヤでの利用が可能です。

OSS 版ではすでに多くの情報が日本語でも調べることが可能なため、本ワークショップはエンタープライズ機能に特化した内容にしています。**Terraform のコアの機能を学習する内容ではないのでご注意ください。**

## Pre-requisite

* 環境
	* macOS or Linux

* ソフトウェア
	* Terraform
	* jq / watch / curl
	* git cli
	* aws / gcloud

* アカウント
	* GitHub
	* Terraform Cloud
	* AWS / GCP

## 資料

* [Terraform Enterprise(有償版)機能](https://www.hashicorp.com/en/products/terraform/features)

## アジェンダ
* [初めての Terraform](./contents/hello-terraform.md)
* [Terraform Cloud によるリモートステート管理](./contents/tfc-remote-state.md)
* VCS 連携 ([GitHub](./contents/vcs.md), [Azure DevOps](./contents/vcs-azure.md))
* [Secure Variable Storage](./contents/variables.md)
* [Enterprise 機能 1: RBAC](./contents/teams.md)
* [Enterprise 機能 2: Private Module Registry](./contents/module.md)
* [Enterprise 機能 3: Terraform Enterprise API](./contents/tf-api.md)
* [Enterprise 機能 4: Notifications](./contents/notifications.md)
* CLI Drive Run
* [API Drive Run](./contents/api-driven-run.md)
* Terraform Enterprise のインストール
