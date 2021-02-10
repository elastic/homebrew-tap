# Elastic Homebrew Tap

This tap is for products in the Elastic stack.

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

## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://github.com/Homebrew/brew/blob/master/docs/README.md).
