# Agent guidance

## Repository purpose

See [README.md](README.md) for why this repository exists, who or what uses it, and its responsibility boundary.

## AI attribution

For every AI tool that materially contributes to code, tests, documentation, configuration, or the substance of a change:

- Resolve the tool's runtime identity and add one unformatted trailer to the commit message. Use the exact model or agent slug and reasoning effort whenever exposed; omit unavailable components rather than guessing:

  ```text
  Assisted-by: <tool name> (<most specific verified runtime identity>)
  ```

- Repeat the same trailer in the pull-request description.
- Preserve the spelling and specificity of exposed runtime values; do not shorten a specific model slug to a broader model family.
- Preserve valid tool-native attribution, such as `Made with [Cursor](https://cursor.com)` or a genuine `Co-authored-by` trailer, in addition to `Assisted-by`.
- Never invent a bot identity, model name, or email address.
- Keep trailers on their own lines without bullets, Markdown emphasis, or surrounding underscores.
- Keep the human author or committer accountable for understanding and verifying the change.

For a squash merge, verify that the final squash commit message contains every attribution trailer. GitHub may populate that message from the pull-request description, commit information, or only the pull-request title depending on repository settings, so putting attribution in the PR description improves preservation but does not guarantee it.

When preparing a commit or pull request, offer to create it with the correct attribution. If the user will create it manually, show the exact trailers to copy into both places.

## Secret handling

- Never place credentials, tokens, private keys, cookies, or production secret values in tracked files, examples, tests, prompts, logs, or generated output.
- Store CI secrets in the repository-scoped CI Vault path or another approved Vault path and inject them at runtime. Follow [Using Secrets in CI](https://codex.elastic.dev/r/platform-engineering-productivity/tooling-services/buildkite/vault-secrets).
- Hermit pins Gitleaks 8.30.1 and pre-commit 4.6.2. The shared `elastic/gitleaks-hooks` hook (v1.0.0) scans staged content locally (this repository has no Buildkite pipeline, so there is no CI range scan).
- Install the staged hooks with `./bin/pre-commit install`; the Gitleaks hook catches detected material before it enters a normal commit. Before committing or pushing, run `./bin/gitleaks dir --no-banner --redact=100 .`. For an adoption or incident check, run `GIT_CONFIG_GLOBAL=/dev/null ./bin/gitleaks git --no-banner --redact=100 --log-opts=--all .` from a complete clone.
- Treat any detected secret as exposed: stop, remove it, and arrange rotation or revocation before continuing. Do not print the value while triaging it.
- Never bypass push protection or secret scanning, select a GitHub bypass reason, use `--no-verify` or `SKIP=gitleaks`, disable a scanner, or add an allowlist or suppression unless the user explicitly requests that exact override after reviewing the finding and consequence.
- A generic request to finish, commit, push, merge, or open a pull request does not authorize an override.
