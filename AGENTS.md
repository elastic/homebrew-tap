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
