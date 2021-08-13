# Homebrew Tap Updater Scripts

These scripts help with updating and testing the homebrew-tap formulas. 

# Usage

The entrypoint for ci `release.sh`:

```bash
.ci/release.sh "$DOWNLOAD_BASE" "$VERSION"
```

This invokes the update, release preparation, and patch file creation for
integration with the release process.

# Individual scripts

## Updating

```bash
BUILD_ID=1.2.3-example
VERSION=1.2.3
env DOWNLOAD_BASE=https://staging.elastic.co/$BUILD_ID/downloads \
  .ci/update.sh $VERSION
```

This will modify the homebrew files locally, run through installing each one,
and update the necessary values. This might take a while, since all the
artifacts will need to be downloaded to the local machine.

Once that is complete, changes can be inspected in the local repository.

## Testing

To run the homebrew automated tests, use the following script:

```bash
.ci/test.sh "$DOWNLOAD_BASE" "$VERSION"
```

For example to run the tests for the `8.0.0-SNAPSHOT` version:
```bash
.ci/test.sh "https://snapshots.elastic.co/downloads" "8.0.0-SNAPSHOT"
```

This will not make any changes to the repository.

## Preparing for a Release

Once a final build candidate is ready and has gone through the `update.sh` and
`test.sh` scripts, update to the final production URLs with:

```bash
.ci/update-to-production-downloads.sh
```
