# New repository checklist

Use this checklist every time a new repository is created in the **ops-lane** organisation.
Copy it into an issue in the new repository and tick items off as you go.

## 1. Basics

- [ ] Clear repository name (lowercase, `kebab-case`)
- [ ] Short description and relevant topics set (repository home → ⚙️ next to *About*)
- [ ] Visibility chosen deliberately (private by default, public only when intended)
- [ ] `README.md` with purpose, setup and how to run locally
- [ ] `.gitignore` suitable for the language/framework
- [ ] `LICENSE` added (public repositories only)
- [ ] Default branch is `main`

## 2. Labels

The issue templates in this organisation apply these labels automatically.
A label that does not exist in the repository is **silently skipped**, so create them first.

| Label | Colour | Description | Default on GitHub? |
|---|---|---|---|
| `bug` | `d73a4a` | Something is not working | ✅ |
| `enhancement` | `a2eeef` | New feature or request | ✅ |
| `tech-debt` | `fbca04` | Refactoring, cleanup or upgrades | ❌ create |
| `security` | `b60205` | Security issue or hardening task | ❌ create |

- [ ] All labels above exist in the repository

Quick setup with the [GitHub CLI](https://cli.github.com/), run from a clone of `ops-lane/.github`:

```bash
./scripts/setup-labels.sh ops-lane/<repository>
```

## 3. Security

*Settings → Advanced Security* (called *Code security* on some plans)

- [ ] **Private vulnerability reporting** enabled (required for the link in `SECURITY.md` and the security issue template)
- [ ] **Dependency graph** enabled
- [ ] **Dependabot alerts** enabled
- [ ] **Dependabot security updates** enabled
- [ ] **Secret scanning** and **push protection** enabled
- [ ] **Code scanning (CodeQL)** enabled with *Default setup*
- [ ] `.github/dependabot.yml` added for version updates (see example below)

> [!NOTE]
> Secret scanning and code scanning are free for public repositories.
> For private repositories they require GitHub Secret Protection / Code Security.

Example `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "pip"          # npm, docker, composer, ...
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

## 4. Branch protection

*Settings → Rules → Rulesets → New branch ruleset* targeting the default branch:

- [ ] Require a pull request before merging
- [ ] Require status checks to pass (once CI exists)
- [ ] Block force pushes
- [ ] Restrict deletions
- [ ] Require conversation resolution before merging (optional)

## 5. General settings

*Settings → General*

- [ ] Merge options: allow **squash merging**; disable merge commits and rebase merging unless needed
- [ ] **Automatically delete head branches** enabled
- [ ] **Always suggest updating pull request branches** enabled
- [ ] Unused features disabled (Wiki, Projects, Discussions)

## 6. GitHub Actions

*Settings → Actions → General*

- [ ] Workflow permissions set to **Read repository contents and packages permissions**
- [ ] *Allow GitHub Actions to create and approve pull requests* disabled unless needed
- [ ] Secrets and variables stored in *Settings → Secrets and variables*, never in code
- [ ] Environments (`staging`, `production`) created with protection rules where deployments happen

## 7. Ownership

- [ ] `.github/CODEOWNERS` added so reviewers are requested automatically
- [ ] Correct team/collaborator access configured (*Settings → Collaborators and teams*)

## 8. Inherited from this repository

These files come from [`ops-lane/.github`](https://github.com/ops-lane/.github) automatically.
Only add them to the new repository if it needs something **different**:

- Issue templates (`ISSUE_TEMPLATE/`)
- Pull request template (`pull_request_template.md`)
- Security policy (`SECURITY.md`)

> [!IMPORTANT]
> If a repository has its own `.github/ISSUE_TEMPLATE/` folder, **none** of the organisation issue templates are used.
