# Elastic Homebrew Tap

This tap is for products in the Elastic stack.

**WARNING: main is now the default branch**

Since October 2021, the default branch is renamed from `master` to `main`.

The `master` branch is no longer updated and will be **deleted on December 1st, 2021**.

Please [follow the instructions to update](#how-do-i-ensure-my-configuration-is-up-to-date) your configuration.


## How do I install these formulae?

Install the tap via:

    brew tap elastic/tap

Then you can install individual products via:

    brew install elastic/tap/elasticsearch-full

The following products are supported:

* Elasticsearch `brew install elastic/tap/elasticsearch-full`
* Logstash `brew install elastic/tap/logstash-full`
* Kibana `brew install elastic/tap/kibana-full`
* Beats
  * Auditbeat `brew install elastic/tap/auditbeat-full`
  * Filebeat `brew install elastic/tap/filebeat-full`
  * Heartbeat `brew install elastic/tap/heartbeat-full`
  * Metricbeat `brew install elastic/tap/metricbeat-full`
  * Packetbeat `brew install elastic/tap/packetbeat-full`
* APM server `brew install elastic/tap/apm-server-full`
* Elastic Cloud Control (ecctl) `brew install elastic/tap/ecctl`

For Logstash, Beats and APM server, we fully support the OSS distributions
too; replace `-full` with `-oss` in any of the above commands to install the 
OSS distribution. Note that the default distribution and OSS distribution of
a product can not be installed at the same time.

## How do I ensure my configuration is up to date?

Run the following command to update your configuration:

    brew tap --repair
    brew update -v

Verify your configuration is based on the `main` branch with:

    git -C /opt/homebrew/Library/Taps/elastic/homebrew-tap status

You should have the following output:

    On branch main
    Your branch is up to date with 'origin/main'.

## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://github.com/Homebrew/brew/blob/master/docs/README.md).

## Troubleshooting
### Calling bottle :unneeded is deprecated!

When I execute `brew update`, the following warning appears
  ```
  Warning: Calling bottle :unneeded is deprecated! There is no replacement.
  ```
  This is related to your configuration not being up-to-date. Your are still using the legacy `master` branch which is not updated anymore. Please [follow the instructions to update](#how-do-i-ensure-my-configuration-is-up-to-date) your local configuration to use the `main` branch.
