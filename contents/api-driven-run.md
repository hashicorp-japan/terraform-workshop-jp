# API Drive Runs

TFC (*Terraform cloud*) 及び TFE (*Terraform Enterprise*)では、3 つの Apply の方法があります。

- CLI Driven
- VCS Driven
- API Driven

ここでは API Driven のやり方を試していきます。
API Driven を用いることで、CI ツールやカスタムのシステムなどで管理される Terraform のコードを API 呼び出しのみで実行することができます。


## 事前準備

ここでの作業を行う前に以下のものを準備ください。

- [TFC の**API Token**](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html)
  - User API token もしくは Team API token を発行してください。
  - Plan, Apply, upload states の権限が必用なので、対象となる Workspace へ Write が許可されていることを確認してください。
- TFC の**Organization**名
- TFC の**Workspace**名
- TFC の**Workspace**の ID
  - Workspace ID は TFC の UI もしくは API から取得できます。
  - UI の場合
    - Workspace　→　Settings　→　General　→　ID
  - API の場合
```shell
export ORGANIZATION=<Organization名>
export WORKSPACE_NAME=<Workspace名>
export TOKEN=<API Token>

curl --header "Authorization: Bearer ${TOKEN}"   --header "Content-Type: application/vnd.api+json"   https://app.terraform.io/api/v2/organizations/${ORGANIZATION}/workspaces/${WORKSPACE_NAME} | jq -r '.data.id'
```

## 大まかな流れ

API による Run の実行は以下の流れで行われます。

1. Configuration version の作成
2. Terraform のコードを Configuration version へアップロード
3. Run に対して Apply を作成
   - **注意** Workspace の Apply Method が`Auto apply`に設定されている場合は自動的に Apply が作成されます。

* 詳細については[こちら](https://www.terraform.io/docs/cloud/run/api.html)を参照ください。


## Configuration version の作成

[Configurationo version](https://www.terraform.io/docs/cloud/api/configuration-versions.html#create-a-configuration-version)はアップロードする Terraform コードへの参照用リソースです。Configuration version を作成すると、Terraform コードをアップロードする先の URL が取得できます。

Workspace に対して Configuration version を作成します。この例では、`data.attributes.auto-queue-runs`に`true`を指定しています。この設定では Terraform コードがアップロードされると自動的に Plan＆Apply が実行されます。


```shell
export WORKSPACE_ID=<WorkspaceのID>

cat << EOF > configuration_version.json
{
  "data": {
    "type": "configuration-versions",
    "attributes": {
      "auto-queue-runs": true,
      "speculative": false
    }
  }
}
EOF

curl --header "Authorization: Bearer ${TOKEN}" --header "Content-Type: application/vnd.api+json" --request POST --data @configuration_version.json https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}/configuration-versions
```

成功すると以下のようなレスポンスが返ってきます。

```json
{
  "data": {
    "id": "cv-RopxxxXWJR1QLq8D",
    "type": "configuration-versions",
    "attributes": {
      "auto-queue-runs": true,
      "error": null,
      "error-message": null,
      "source": "tfe-api",
      "status": "pending",
      "status-timestamps": {},
      "changed-files": [],
      "upload-url": "https://archivist.terraform.io/v1/object/dmF1bHQ6djE6MVZRc0JpbVY2b0tuV0dydmVXSVVyRzJ2VEZuSmdBRmo2QWM5TmNGdFRVK29tTHRKdU9CdGJsWjNablR0ZWsrQVEvQkxHbHFnY3lRVUJ1NEt4dHhnWjVRN29BVXQrL0w1L0Y1eE1IeFhtY3hZUkRMaFYvUW1QUG51MzVkeUt4eDZ2U3VQc09jVXlWQ1YrZ0c1WHRzUTR1M0hJRU4rZkRna1k0WGJqaCt0ZFhFRTdaS3EyREJnTzI0YkFyQ0FqbFNzdTg5QnhPTVFFdWRsei95N2NlaERvUkxQY0dacVBEN25KOXFkbFRQeUxLV2hPNWp1ajJvaG1CRlVQZmJZZzR4cHlLc25hOGFZbGFBSWgyMFVNSzRPTGtvZkpkRGhzdTg9"
    },
    "relationships": {
      "ingress-attributes": {
        "data": null,
        "links": {
          "related": "/api/v2/configuration-versions/cv-RopxxxXWJR1QLq8D/ingress-attributes"
        }
      }
    },
    "links": {
      "self": "/api/v2/configuration-versions/cv-RopxxxXWJR1QLq8D"
    }
  }
}
```

このレスポンスの`.data.attributes.upload-url`が Terraform コードをアップロードする先になります。

## Terraform のコードを Configuration version へアップロード

次に Terraform のコード群をアップロードするために`tar.gz`フォーマットへパッケージングします。この章の目的は Provisioning ではなく API Driven の動作方法なので、ここでは簡単に実行できるシンプルな Terraform コードを使います。

```shell
mkdir tf_test
cat << EOF > tf_test/main.tf
resource "random_pet" "pet" {
	keepers = {
		val = timestamp()
	}
}

output "pet" {
	value = random_pet.pet.id
}
EOF

tar cvfz main.tar.gz -C tf_test .
```

>**Note**
>
>tar.gz パッケージのルートディレクトリが、そのまま Terraform 実行時のディレクトリになります。以下のような構成になっていれば OK です。
```shell
$ tar tvfz main.tar.gz
drwxr-xr-x  0 masa   staff       0  4 14 14:59 ./
-rw-r--r--  0 masa   staff     130  4 14 14:59 ./main.tf
```

それでは[アップロード用の API](https://www.terraform.io/docs/cloud/api/configuration-versions.html#upload-configuration-files)を使ってパッケージをアップロードします。

```shell
curl --header "Authorization: Bearer ${TOKEN}" --header "Content-Type: application/vnd.api+json" --request PUT --data-binary @main.tar.gz https://archivist.terraform.io/v1/object/dmF1bHQ6djE6MVZRc0JpbVY2b0tuV0dydmVXSVVyRzJ2VEZuSmdBRmo2QWM5TmNGdFRVK29tTHRKdU9CdGJsWjNablR0ZWsrQVEvQkxHbHFnY3lRVUJ1NEt4dHhnWjVRN29BVXQrL0w1L0Y1eE1IeFhtY3hZUkRMaFYvUW1QUG51MzVkeUt4eDZ2U3VQc09jVXlWQ1YrZ0c1WHRzUTR1M0hJRU4rZkRna1k0WGJqaCt0ZFhFRTdaS3EyREJnTzI0YkFyQ0FqbFNzdTg5QnhPTVFFdWRsei95N2NlaERvUkxQY0dacVBEN25KOXFkbFRQeUxLV2hPNWp1ajJvaG1CRlVQZmJZZzR4cHlLc25hOGFZbGFBSWgyMFVNSzRPTGtvZkpkRGhzdTg9
```

この API が成功すると TFC 上の Workspace で Plan＆Apply が実行されます。

## Run に対して Apply を作成

> **Note**
>
> Workspace の Apply Method が`Auto apply`に設定されている場合は自動的に Apply が作成されますので、このセクションはスキップできます。

Workspace の Apply Method が`Manual apply`に設定されている場合、実際の Apply を実行する際に**Confirm apply**の承認をする必要があります。ここでは、その承認を API で行なうやり方を試します。

まずは Workspace から Apply したい Run の ID を取得します。[List Runs in a Worrkspace](https://www.terraform.io/docs/cloud/api/run.html#list-runs-in-a-workspace)の API を使用します。

```shell
export WORKSPACE_ID=<WorkspaceのID>

curl --header "Authorization: Bearer ${TOKEN}" --header "Content-Type: application/vnd.api+json" https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}/runs?page%5Bsize%5D=1
```

成功すると以下のようなレスポンスが返ってきます。

<details><summary>List Runのレスポンス</summary>

```json
{
  "data": [
    {
      "id": "run-bc4WDCExqr5CF4Ad",
      "type": "runs",
      "attributes": {
        "actions": {
          "is-cancelable": false,
          "is-confirmable": true,
          "is-discardable": true,
          "is-force-cancelable": false
        },
        "canceled-at": null,
        "created-at": "2020-04-14T06:34:05.962Z",
        "has-changes": true,
        "is-destroy": false,
        "message": "New configuration uploaded via the Terraform Cloud API",
        "plan-only": false,
        "source": "tfe-configuration-version",
        "status-timestamps": {
          "planned-at": "2020-04-14T06:34:22+00:00",
          "planning-at": "2020-04-14T06:34:06+00:00",
          "plan-queued-at": "2020-04-14T06:34:06+00:00",
          "cost-estimated-at": "2020-04-14T06:34:29+00:00",
          "plan-queueable-at": "2020-04-14T06:34:06+00:00",
          "cost-estimating-at": "2020-04-14T06:34:22+00:00"
        },
        "status": "cost_estimated",
        "trigger-reason": "manual",
        "permissions": {
          "can-apply": true,
          "can-cancel": true,
          "can-discard": true,
          "can-force-execute": true,
          "can-force-cancel": true,
          "can-override-policy-check": true
        }
      },
      "relationships": {
        "workspace": {
          "data": {
            "id": "ws-ajLLjugn2ngooBV9",
            "type": "workspaces"
          }
        },
        "apply": {
          "data": {
            "id": "apply-YnTxd3Jyca6QxRyz",
            "type": "applies"
          },
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/apply"
          }
        },
        "configuration-version": {
          "data": {
            "id": "cv-Fcd8m1fT1SYHukBV",
            "type": "configuration-versions"
          },
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/configuration-version"
          }
        },
        "cost-estimate": {
          "data": {
            "id": "ce-QNvdDKY5LaFfX2K6",
            "type": "cost-estimates"
          },
          "links": {
            "related": "/api/v2/cost-estimates/ce-QNvdDKY5LaFfX2K6"
          }
        },
        "created-by": {
          "data": {
            "id": "user-F1BcjnRCZtW8irfQ",
            "type": "users"
          },
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/created-by"
          }
        },
        "plan": {
          "data": {
            "id": "plan-QDeb8Th3SKGjmMfP",
            "type": "plans"
          },
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/plan"
          }
        },
        "run-events": {
          "data": [
            {
              "id": "re-zEvX8pBeQmveXGCU",
              "type": "run-events"
            },
            {
              "id": "re-H14w91kpaBkYSZE3",
              "type": "run-events"
            },
            {
              "id": "re-PoqrfPvkTLeuRUyu",
              "type": "run-events"
            },
            {
              "id": "re-DQHX1WNuvtmkUf8e",
              "type": "run-events"
            },
            {
              "id": "re-G6XjkF2uCbG5LJ9T",
              "type": "run-events"
            },
            {
              "id": "re-7LsT4e4tKqUxk8bn",
              "type": "run-events"
            }
          ],
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/run-events"
          }
        },
        "policy-checks": {
          "data": [],
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/policy-checks"
          }
        },
        "comments": {
          "data": [],
          "links": {
            "related": "/api/v2/runs/run-bc4WDCExqr5CF4Ad/comments"
          }
        }
      },
      "links": {
        "self": "/api/v2/runs/run-bc4WDCExqr5CF4Ad"
      }
    }
  ],
  "links": {
    "self": "https://app.terraform.io/api/v2/workspaces/ws-ajLLjugn2ngooBV9/runs?page%5Bnumber%5D=1&page%5Bsize%5D=1",
    "first": "https://app.terraform.io/api/v2/workspaces/ws-ajLLjugn2ngooBV9/runs?page%5Bnumber%5D=1&page%5Bsize%5D=1",
    "prev": null,
    "next": "https://app.terraform.io/api/v2/workspaces/ws-ajLLjugn2ngooBV9/runs?page%5Bnumber%5D=2&page%5Bsize%5D=1",
    "last": "https://app.terraform.io/api/v2/workspaces/ws-ajLLjugn2ngooBV9/runs?page%5Bnumber%5D=2&page%5Bsize%5D=1"
  },
  "meta": {
    "pagination": {
      "current-page": 1,
      "prev-page": null,
      "next-page": 2,
      "total-pages": 2,
      "total-count": 2
    }
  }
}
```
</details>


このレスポンスに含まれる`.data[0].id`が Run ID になります。この例ですと、`run-bc4WDCExqr5CF4Ad`になります。

それでは取得した Run ID に対して[Apply a Run の API](https://www.terraform.io/docs/cloud/api/run.html#apply-a-run)を実行します。

```shell
export RUN_ID=<取得したRun ID>

cat << EOF >> apply_run.json
{
  "comment": "うん、いいねっ!"
}
EOF

curl --header "Authorization: Bearer ${TOKEN}" --header "Content-Type: application/vnd.api+json" --request POST --data @apply_run.json https://app.terraform.io/api/v2/runs/${RUN_ID}/actions/apply
```

この API が成功すると`Confirm & Apply`が承認され Apply が実行されているはずです。

## まとめ

Terraform cloud 及び Terraform enterprise は[ほぼ全ての機能が API でアクセス](https://www.terraform.io/docs/cloud/api/index.html)できます。ここでは既存の Workspace に対し Terraform コードをアップロードして Run を行いました。それ以外にも Workspace の Lock や Run の実行状態の取得など、非常に細かに制御する事ができます。

- 皆様のワークフローに合わせた作り込み
- Terraform バイナリが使えないような環境からも Provisioning 可能
  - CI/CD ツール
  - 独自の Provisioning システム
  - コンテナやサーバーレス
  - など

ぜひ Terraform cloud API を活用してハッピーな Provisioning ライフをおくってください！
