# Version Control System連携を試す

TFCには三つのApplyのトリガーを使うことができます。

* API Driven
* CLI Drive
* VCS Driven

ここではVCS DriveパターンのWebhookでの実行を試してみます。

## GitHubとTerraform Cloudのセットアップ

ここではTerraform Cloud(以下、TFC)を使ってEnterprise版の機能を使ってみます。Terraform Cloudには機能が限定的な無償版とEnterpriseのライセンスでアクティベートされる有償版があります。このハンズオンでは講師が事前に期限限定でアクティベートしてあります。

TFCにアクセスし最初のセットアップを行いましょう。

ワークスペースを作成し、そこにVCSとの連携の設定を行います。対応しているVCSは以下の通りです。

* [GitHub](https://www.terraform.io/docs/cloud/vcs/github.html)
* [GitHub Enterprise](https://www.terraform.io/docs/cloud/vcs/github-enterprise.html)
* [GitLab.com](https://www.terraform.io/docs/cloud/vcs/gitlab-com.html)
* [GitLab EE and CE](https://www.terraform.io/docs/cloud/vcs/gitlab-eece.html)
* [Bitbucket Cloud](https://www.terraform.io/docs/cloud/vcs/bitbucket-cloud.html)
* [Bitbucket Server](https://www.terraform.io/docs/cloud/vcs/bitbucket-server.html)

以下はGitHubの手順ですが、違うVCSで実施した場合はリンクの手順を参考にしてください。

### GitHubレポジトリ作成

GitHub上に`tf-handson-workshop`という名前のパブリックレポジトリを作成してください。

### GitHubのOAuth Applicationの作成

トップ画面の`Settings`から`VCS Providers`を選んでください。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-1.png?response-content-disposition=inline&X-Amz-Security-Token=AgoJb3JpZ2luX2VjEKr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDmFwLW5vcnRoZWFzdC0xIkcwRQIgQ%2FCUTbZslaR1E2O53g2PPMkxGDSgG7KaieHPUM1WZK8CIQDTP92GAdPXlWUhQfSv5dkNOidPWPstNFPE6XIRvptPNirbAwhDEAAaDDY0MzUyOTU1NjI1MSIMYLIZlr2dXRtvsFtEKrgDB3LFAGcmLgXd63J5b0nzYj8QmDbC27fqYEsunl7bzFhY3rPNKC6lajQ2gSISm3bSnKV%2F%2BQP5MX16KaG%2B54IWo8au07rlzGofEhB9ri9WwNTiJXlyS479WAcQh54Isu5DZgiIL7FvwQ2da9z3njykywGdEWDYJyEpgBqSdheVJcDALPd5pff8vYSZLym6BBPfrrfrlwxDP2smHYT6Cn2bK%2BeSejnqxECPR24S3%2Fl2dMdxbsz5myN4kkOrkk7sVhWqdZNCFvfj0dvuT1ciER1NddDHsUth0MWhfWNBr9EWnI%2Bb9dbEGNZnS7SQ0x6OsOpcHvVrlriPr5T7DBrEA7GVBVO%2BxZzfYwUo2Uf2JLDbPLCutQNpUaHIXutofb%2BQfG9TAzlcZdf1yHDeYXuANyJxf%2Bh6CmCn5Y6MfelgaFcXrhx9BPYOsZP464gThFBSax%2Fq%2Bu7PDEOWGTqzOO4zfKfSO3sp7C%2FFSJYIW6Xl4g3roF63n1YV2NF2qLFAAxafgHFIRz22AE1pv2kfUnQDy8oqxPNYlEA0uuxF3v%2BdmBbRh213DO%2FWsmww%2FgGrYHPnzEkVZAbddKS19AQw3qTZ6gU6tAEuuyAYej4QTfuWnlnLYWpVobAfhVswPQl8VRjMXhAlvhWvlcbvBFZ6E2e4A60RkocIDUj8NnJJCxMEDY0bgUSPt8Bbs%2FjBLuIbyZveye2HE9LHwXkqgzLER4tqLIzhzyPZ0BZZQCIycxFSvb%2F9qAO6csW3wXRlicICd006ekeTxDihpTvp6p%2BKFBYIj4ddfn9WVipd0ks0B%2FvSU29zfGDTiLXnjOTM8oueuZySZYjg97T2E3U%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20190816T122624Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAZLVKZYENZZAGQJK6%2F20190816%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Signature=8b942c677cb8902c190b275eedd546347e15818fbb59583251b3de8ef839d0d8)

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-2.png)


次に[こちら](https://github.com/settings/applications/new)にアクセスしTFC用のキーを発行します。

OAuthアプリケーションの登録画面で以下のように入力してください。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-3.png)

* Application Name : Terraform Cloud
* Homepage URL: https://app.terraform.io
* Authorization callback URL: https://example.com/replace-this-later

入力したら`Register`をクリックします。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-4.png)

次にTFCに戻り`Add VCS Provider`を選択します。`Client ID`と`Client Secret`の欄に上のGitHub上の画面で取得した値をコピペしてください。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-5.png)

`Create`をクリックします。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-6.png)

VCS Providerが一つ追加され、Callback URLが生成されたのでこれをコピーし、これをGitHubの`Authorization callback URL`の項目を置き換えます。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/hello-7.png)

これでSaveし、VCSの設定は完了です。次にこれを紐付けたワークスペースを作成します。

## Workspaceの作成

まずワークスペースのレポジトリを作ります。

```shell
mkdir -p tf-workspace/tf-handson-workshop
cd path/to/tf-workspace/tf-handson-workshop
```

以下のファイルを作ります。

```shell
cat <<EOF > main.tf
terraform {
	required_version = " 0.12.6"
}
EOF
```

GitHubにプッシュして連携の確認をしてみましょう。

```shell
git init
git add main.tf
git commit -m "first commit"
git remote add origin https://github.com/tkaburagi/tf-handson-workshop.git
git push -u origin master
```

TFC上でWorkspaceを作成します。トップ画面の`+ New Workspace`を選択し、GitHubを選択します。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/vcs-1.png)

レポジトリは先ほど作成した`tf-handson-workshop`を選択し、`Create Workspace`をクリックします。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/vcs-2.png)

成功の画面が出たら`Queue Plan`を実行して動作を確認してみましょう。ここではからのコードを実行しているため`Apply will not run`となるはずです。

![](https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/terraform-workshop/vcs-4.png)


次以降の章で実際のコードをApplyしてGitHubを通したインフラのプロビジョニングを試してみます。

## 参考リンク
* [VCS Integration](https://www.terraform.io/docs/cloud/vcs/index.html)
* [VCS Driven Run](https://www.terraform.io/docs/cloud/run/ui.html)
