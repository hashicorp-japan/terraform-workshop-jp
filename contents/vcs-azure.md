# Version Control System 連携を試す

TFC には三つの Apply のトリガーを使うことができます。

* API Driven
* CLI Drive
* VCS Driven

ここでは VCS Drive パターンの Webhook での実行を試してみます。

## GitHub と Terraform Cloud のセットアップ

ここでは Terraform Cloud(以下、TFC)を使って Enterprise 版の機能を使ってみます。Terraform Cloud には機能が限定的な無償版と Enterprise のライセンスでアクティベートされる有償版があります。このハンズオンでは講師が事前に期限限定でアクティベートしてあります。

TFC にアクセスし最初のセットアップを行いましょう。

ワークスペースを作成し、そこに VCS との連携の設定を行います。対応している VCS は以下の通りです。

* [GitHub](https://www.terraform.io/docs/cloud/vcs/github.html)
* [GitHub Enterprise](https://www.terraform.io/docs/cloud/vcs/github-enterprise.html)
* [GitLab.com](https://www.terraform.io/docs/cloud/vcs/gitlab-com.html)
* [GitLab EE and CE](https://www.terraform.io/docs/cloud/vcs/gitlab-eece.html)
* [Bitbucket Cloud](https://www.terraform.io/docs/cloud/vcs/bitbucket-cloud.html)
* [Bitbucket Server](https://www.terraform.io/docs/cloud/vcs/bitbucket-server.html)
* [Azure DevOps Services](https://www.terraform.io/docs/cloud/vcs/azure-devops-services.html)
* [Azure DevOps Server](https://www.terraform.io/docs/cloud/vcs/azure-devops-services.html)

以下は Azure DevOps の手順ですが、違う VCS で実施した場合はリンクの手順を参考にしてください。

### Azure DevOps Progects 作成

 [こちらから](https://aex.dev.azure.com/me?mkt=en-US)Organization を作成してください。次に、

```
"tf-handson-workshop"という名前のパブリックプロジェクトを作成してください。
```
### GitHub の OAuth Application の作成

トップ画面の`Settings`からサイドメニューの`Version control` -> `Providers`を選んでください。この画面はこのままにしておいてください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-1.png">
</kbd>  

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/hello-2.png">
</kbd>  

次に[こちら](https://aex.dev.azure.com/app/register?mkt=en-US)にアクセスし TFC 用のキーを発行します。

OAuth アプリケーションの登録画面で以下のように入力してください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-1.png">
</kbd>  

* Company name: <COMPNAY_NAME>
* Application Name : Terraform Cloud
* Application site: `https://app.terraform.io`
* Authorization callback URL: `https://example.com/replace-this-later`
* Authorized scopes: Code(read), Code(status)にチェック

入力したら`Create Application`をクリックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-2.png">
</kbd>

`App ID`と`Client Secret`はコピーしておいてください。この画面はこのままにしておいてください。

次に TFC に戻り`Add VCS Provider`を選択します。

`Version Control System(VCS) Provider`からプルダウンで`Azure DevOps Services`を選択し、`App ID`と`Client Secret`の欄に上の Azure DevOps 上の画面で取得した値をコピペしてください。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-3.png">
</kbd>

`Add VCS Provider`をクリックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-4.png">
</kbd>

VCS Provider が一つ追加され、Callback URL が生成されたのでこれをコピーし、これを Azure DevOps の`Authorization callback URL`の項目を置き換えます。

Azure DevOps の画面に戻り、`Edit Application`をクリックし、`Authorization callback URL`の`https://example.com/replace-this-later`をコピーした Callback URL に変更します。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-5.png">
</kbd>

これで Save changes しましょう。

最後にトップ画面の`Settings`からサイドメニューの`Version control` -> `Providers`から先ほど追加した GitHub の`Connect organization username`をクリックして認証行ってください。

これで VCS の設定は完了です。次にこれを紐付けたワークスペースを作成します。

## Workspace の作成

まずワークスペースのレポジトリを作ります。

```shell
$ mkdir -p tf-workspace/tf-handson-workshop
$ cd tf-workspace/tf-handson-workshop
```

以下のファイルを作ります。

```shell
$ cat <<EOF > main.tf
terraform {
}
EOF
```

Azure DevOps にプッシュして連携の確認をしてみましょう。[Azure DevOps のコンソール](https://aex.dev.azure.com/)から先ほど作った Organization->`tf-handson-workshop`を選択し、左カラムの`Repos`から URL をコピーしてください。また、`Generate Git Credentials`からパスワードをコピーしておいて下さい。

```shell
$ export ADO_URL=<YOUR_AZURE_DEVOPS_PROJECT_URL>
$ git init
$ git add main.tf
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin $ADO_URL
$ git push -u origin main
```

TFC 上で Workspace を作成します。トップ画面の`+ New Workspace`を選択し、Azure DevOps を選択します。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-6.png">
</kbd>

レポジトリは先ほど作成した`tf-handson-workshop`を選択し、`Create Workspace`をクリックします。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-azure-7.png">
</kbd>

成功の画面が出たら`Queue Plan`を実行して動作を確認してみましょう。ここでは空のコードを実行しているため`Apply will not run`となるはずです。

<kbd>
  <img src="https://github-image-tkaburagi.s3.ap-northeast-1.amazonaws.com/terraform-workshop/vcs-4.png">
</kbd>


次以降の章で実際のコードを Apply して GitHub を通したインフラのプロビジョニングを試してみます。

## 参考リンク
* [VCS Integration](https://www.terraform.io/docs/cloud/vcs/index.html)
* [VCS Driven Run](https://www.terraform.io/docs/cloud/run/ui.html)
