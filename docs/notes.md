# Notes: managing repositories with Terraform

Goal: create a complete repository in **ops-lane**, including every setting from the
[new repository checklist](new-repository-checklist.md), using Terraform instead of clicking through the UI.

Provider: [`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest/docs)

## Checklist → Terraform resources

| Checklist item | Resource | Supported? |
|---|---|---|
| Name, description, topics, visibility, `.gitignore`, licence | `github_repository` | ✅ |
| Disable Wiki/Projects/Discussions, squash merge only, delete head branches, suggest branch updates | `github_repository` | ✅ |
| Default branch `main` | `github_branch_default` | ✅ |
| Labels | `github_issue_label` / `github_issue_labels` | ✅ |
| Dependabot alerts | `github_repository` (`vulnerability_alerts`) | ✅ |
| Dependabot security updates | `github_repository_dependabot_security_updates` | ✅ |
| Secret scanning + push protection | `github_repository` (`security_and_analysis`) | ✅ |
| Branch protection (ruleset) | `github_repository_ruleset` | ✅ |
| Actions permissions, read-only `GITHUB_TOKEN` | `github_actions_repository_permissions`, `github_workflow_repository_permissions` | ✅ |
| Secrets and environments | `github_actions_secret`, `github_repository_environment`, `github_actions_environment_secret` | ✅ (see risks) |
| `CODEOWNERS`, `dependabot.yml` | `github_repository_file` | ✅ |
| Team / collaborator access | `github_team_repository`, `github_repository_collaborator` | ✅ |
| Private vulnerability reporting | – | ⚠️ Unverified, check the provider docs |
| CodeQL default setup | – | ⚠️ No known dedicated resource; alternative: ship a CodeQL workflow via `github_repository_file` |

## Example

A reusable module with our defaults; each new repository is one entry in a map.

```hcl
# repos.tf
module "repo" {
  source   = "./modules/repository"
  for_each = {
    "example-api"   = { description = "Example backend", visibility = "private", topics = ["django"] }
    "example-tools" = { description = "Example tooling", visibility = "public",  topics = ["automation"] }
  }

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  topics      = each.value.topics
}
```

```hcl
# modules/repository/main.tf (abridged)
resource "github_repository" "this" {
  name                   = var.name
  description            = var.description
  visibility             = var.visibility
  topics                 = var.topics
  auto_init              = true
  has_wiki               = false
  has_projects           = false
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  delete_branch_on_merge = true
  allow_update_branch    = true
  vulnerability_alerts   = true
  archive_on_destroy     = true # removing a repo from code archives it instead of deleting it

  security_and_analysis {
    secret_scanning                 { status = "enabled" }
    secret_scanning_push_protection { status = "enabled" }
  }
}

resource "github_issue_label" "this" {
  for_each = {
    "tech-debt" = { color = "fbca04", description = "Refactoring, cleanup or upgrades" }
    "security"  = { color = "b60205", description = "Security issue or hardening task" }
  }
  repository  = github_repository.this.name
  name        = each.key
  color       = each.value.color
  description = each.value.description
}

resource "github_repository_ruleset" "main" {
  name        = "protect-main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
    pull_request {
      required_approving_review_count = 0
    }
  }
}
```

## Recommended setup

1. **Separate repository**, e.g. `ops-lane/github-config`. Keep `.github` for templates and policies only.
2. **Remote state** in S3-compatible storage (e.g. MinIO on the NAS) or HCP Terraform (free tier). Never commit state to git.
3. **Authenticate with a GitHub App** instead of a personal access token: finer-grained permissions and not tied to a personal account.
4. **CI with GitHub Actions**: `terraform plan` as a PR comment, `terraform apply` after merging to `main`.
5. **Adopt existing repositories** with `import` blocks so Terraform manages them without recreating them.

## Risks and caveats

- **Drift**: manual changes in the GitHub UI are reverted on the next `apply`. Terraform becomes the single source of truth.
- **Secrets end up in state** in plain text. Secure the state backend, or manage secrets outside Terraform.
- **Deletion**: without `archive_on_destroy` or `lifecycle { prevent_destroy = true }`, removing a block can delete a repository including all its code.
- **Plan limits**: secret scanning and code scanning on private repositories require a paid GitHub plan (Secret Protection / Code Security). Terraform will enable them, but the API errors without a licence.

## Open questions

- [ ] Can private vulnerability reporting be managed with the current provider version?
- [ ] How to handle CodeQL: default setup via API/manual, or a committed workflow file?
- [ ] State backend: MinIO on the NAS or HCP Terraform?
- [ ] Should organisation-level settings (org rulesets, member permissions) be managed too?
