# Scripts for Zabbix

## Installation

On Zabbix server...

```
$ bundle install
```

Put `*.rb` to `/usr/lib/zabbix/externalscripts`.

## Usage

### aws.rb

```
$ /usr/lib/zabbix/externalscripts/aws.rb cloudwatch --help

  NAME:

    cloudwatch

  SYNOPSIS:

    aws.rb cloudwatch [options]

  DESCRIPTION:

    Script to get metric statistics from CloudWatch.

  OPTIONS:

    --region VALUE
        AWS region

    --namespace VALUE
        CloudWatch namespace

    --metric-name VALUE
        CloudWatch metric name

    --dimension-name VALUE
        CloudWatch dimension name

    --dimension-value VALUE
        CloudWatch dimension value

    --statistics VALUE
        CloudWatch statistics method

    --interval VALUE
        CloudWatch statistics interval

    --end-time-offset VALUE
        CloudWatch statistics end time offset

    --period VALUE
        CloudWatch statistics period

    --default-value VALUE
        CloudWatch statistics default value

    --try-count VALUE
        Count to try get metrics

    --retry-interval VALUE
        Interval between tries
```
