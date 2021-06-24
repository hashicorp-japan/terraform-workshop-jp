# Teams in Terraform cloud/enterpise

Terraform cloud free-tier (無料版)にはTeamという概念がありません。よって複数のメンバーで使用するときにアクセス制御をつける事ができません。

その問題を解決するために、Terraform cloud及びEnterpriseには**Roles / Team managerment**という機能が準備されています。
この機能は以下のTerraform offeringで利用可能です。
- Terraform cloud team
- Terraform cloud team & governance
- Terraform Enterprise

Teamに対する権限はOrganizationレベルとWorkspaceレベルの2段階で設定できます。

ここでのエクササイズでは、organization及びWorkspaceに対してTeamを作成し、アクセス権限を付与してみます。

## OrganizationレベルのTeamの作成

まず、[Terraform cloud](https://app.terraform.io/)へアクセスし、Organizationの**Setting >> Teams**へ行きます。

<kbd>
  <img src="../assets/teams/create_team.png">
</kbd>

Teamには以下のような3つの権限をつけることが出来ます。**ここでの権限はOrganizationレベルの権限であり、Workspaceレベルの権限ではありません。**
- Managed Policies
- Manage workspaces
- Manage VCS setting

<kbd>
  <img src="../assets/teams/organization_access.png">
</kbd>

**Create a New Team**から以下の3つのチームを1つづつ作成します。

1. admin
   - adminには3つ全ての権限をつけて下さい。
2. developers
   - 権限は何もつけなくてよいです。（Organizationレベルの権限は付与しない)
3. managers
   - 権限は何もつけなくてよいです。(Organizationレベルの権限は付与しない)

## WorkspaceレベルのTeamの作成

次にWorkspaceレベルのTeamの作成を行います。

Workspaceを開き、**Settings > Team Access**へナビゲートしてください。

<kbd>
  <img src="../assets/teams/workspace_team.png">
</kbd>

ここで先程作成したTeamに、以下のようにWorkspaceレベルのPermissionsを付与してください。

- admin
  - admin
- developers
  - write
- managers
  - read

以下のように表示されればOKです。

<kbd>
  <img src="../assets/teams/workspace_permission.png">
</kbd>

このPermissionについては詳細は[ドキュメント](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html)を参照いただければと思います。簡単にまとめますと：

- Read
  - Stateファイルの参照
  - Run履歴の参照
  - セキュア変数の参照
  - Stateファイルに変更の加わる処理はできない
- Plan
  - Read権限の全て
  - Runの作成（Planの実行可、Applyの実行不可）
- Write
  - Plan権限の全て
  - Stateファイルへの変更（Applyの実行）
  - Run実行の承認
  - セキュア変数の変更
  - WorkspaceのLock/Unlock
- Admin
  - Write権限の全て
  - Workspaceの削除
  - Workspaceへのメンバーの追加・変更
  - Workspace設定（VCSなど）の変更

となります。

## チームメンバーをTeamにアサイン

Teamが設定されたら、admins権限のあるユーザーはチームメンバーをTeamにアサインします。

既にOrganizationに追加されているユーザーであれば、**organizationレベルのSettings >> Teams** からTeamを選択し、**Add a New Team Member**でユーザーを追加します。

<kbd>
  <img src="../assets/teams/add_team_member.png">
</kbd>

これからユーザーを追加する場合は、**organizationレベルのSettings >> Users**の**Invite a user**ボタンからユーザーのTeamを選択してインバイトします。

<kbd>
  <img src="../assets/teams/invite_a_user_button.png">
</kbd>

<kbd>
  <img src="../assets/teams/invite_a_user.png">
</kbd>

## まとめ

Terraform cloud free-tierではWorkspaceへのアクセスがあれば誰でもStateファイルへ変更（Applyの実効）が可能ですが、Terraform cloud paid及びEnterpriseでは、様々な処理に対しアクセス制限を付けることができます。複数のチームメンバーに対し、それぞれ役割に応じた権限を割り当てることで、ルールに応じたワークフローを実現できるのではないでしょうか。

Teamとアクセス制限を駆使してTerraform Cloud/EnterpriseではRBAC（Role based access control)を実現します。
