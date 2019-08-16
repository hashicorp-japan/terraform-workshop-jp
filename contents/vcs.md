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

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-1.png){: .shadow}

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-2.png)


次に[こちら](https://github.com/settings/applications/new)にアクセスしTFC用のキーを発行します。

OAuthアプリケーションの登録画面で以下のように入力してください。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-3.png)

* Application Name : Terraform Cloud
* Homepage URL: https://app.terraform.io
* Authorization callback URL: https://example.com/replace-this-later

入力したら`Register`をクリックします。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-4.png)

次にTFCに戻り`Add VCS Provider`を選択します。`Client ID`と`Client Secret`の欄に上のGitHub上の画面で取得した値をコピペしてください。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-5.png)

`Create`をクリックします。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-6.png)

VCS Providerが一つ追加され、Callback URLが生成されたのでこれをコピーし、これをGitHubの`Authorization callback URL`の項目を置き換えます。

![](https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-7.png)

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
