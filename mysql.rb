#!/usr/bin/env ruby

require "commander/import"
require "mysql2"

program :name,        "GetMySQLMetric"
program :version,     "0.0.1"
program :description, "Script to get data from MySQL."

global_option "-h", "--host VALUE",     String,  "MySQL host."
global_option "-u", "--username VALUE", String,  "MySQL username."
global_option "-p", "--password VALUE", String,  "MySQL password."
global_option "-P", "--port VALUE",     Integer, "MySQL port."

command :status do |c|
  c.syntax      = "mysql.rb status [options]"
  c.description = "Script to get metrics from MySQL."

  c.option "-i", "--item VALUE", String, "Item name of an metric."

  c.action do |args, options|
    options.default(
      host:     "localhost",
      username: "root",
      port:     3306,
    )

    client = Mysql2::Client.new(
      host:     options.host,
      username: options.username,
      password: options.password,
      port:     options.port,
    )

    status = client.query("SHOW STATUS LIKE '#{options.item}'").inject({}) do |acc, h|
      acc.merge h["Variable_name"] => h["Value"]
    end

    say status[options.item]
  end
end
