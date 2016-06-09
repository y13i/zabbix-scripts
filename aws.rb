#!/usr/bin/env ruby

require "commander/import"
require "aws-sdk"
require "retryable"

NoDatapointError = Class.new StandardError

program :name,        "GetAwsMetric"
program :version,     "0.0.1"
program :description, "Script to get data from AWS API."

command :cloudwatch do |c|
  c.syntax      = "aws.rb cloudwatch [options]"
  c.description = "Script to get metric statistics from CloudWatch."

  c.option "--region VALUE",          String,  "AWS region"
  c.option "--namespace VALUE",       String,  "CloudWatch namespace"
  c.option "--metric-name VALUE",     String,  "CloudWatch metric name"
  c.option "--dimension-name VALUE",  String,  "CloudWatch dimension name"
  c.option "--dimension-value VALUE", String,  "CloudWatch dimension value"
  c.option "--statistics VALUE",      String,  "CloudWatch statistics method"
  c.option "--interval VALUE",        Integer, "CloudWatch statistics interval"
  c.option "--end-time-offset VALUE", Integer, "CloudWatch statistics end time offset"
  c.option "--period VALUE",          Integer, "CloudWatch statistics period"
  c.option "--default-value VALUE",   Integer, "CloudWatch statistics default value"
  c.option "--try-count VALUE",       Integer, "Count to try get metrics"
  c.option "--retry-interval VALUE",  Integer, "Interval between tries"

  c.action do |args, options|
    options.default(
      region:          (ENV["AWS_REGION"] || "ap-northeast-1"),
      statistics:      "Average",
      interval:        300,
      end_time_offset: 0,
      period:          60,
      try_count:       3,
      retry_interval:  3,
      default_value:   0,
      precision:       4,
    )

    cloudwatch_client ||= Aws::CloudWatch::Client.new(region: options.region)

    params = {
      namespace:   options.namespace,
      metric_name: options.metric_name,
      start_time:  (Time.now - options.end_time_offset - options.interval),
      end_time:    (Time.now - options.end_time_offset),
      period:      options.period,
      statistics:  [options.statistics],

      dimensions: (
        if options[:dimension_name] and options[:dimension_value]
          [
            {
              name:  options[:dimension_name],
              value: options[:dimension_value],
            }
          ]
        else
          []
        end
      ),
    }

    datapoints = begin
      Retryable.retryable(tries: options.try_count, sleep: options.retry_interval, on: NoDatapointError) do
        response = cloudwatch_client.get_metric_statistics(params)

        abort unless response.successful?

        datapoints = response.data.datapoints

        fail NoDatapointError if datapoints.empty?

        datapoints
      end
    rescue
      say options.default_value
      exit
    end

    datapoint = datapoints.sort_by(&:timestamp).last

    output = if options.precision
      sprintf("%.#{options.precision}f", datapoint.send(options.statistics.downcase.intern).to_f)
    else
      datapoint.send(options.statistics.downcase.intern)
    end

    say output
  end
end
