# bust gem prelude
require 'bundler'
Bundler.setup

# Immunio assumes rails is already loaded.
require 'rails/all'

# Workaround adapters only loaded depending on the database adapter.
if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.4.0')
  # mysql gem no longer builds with later versions
  require 'active_record/connection_adapters/mysql_adapter'
end

require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'

# Activate the agent.
require 'immunio'

if Immunio.agent.agent_enabled
  # Workaround active_record only activated after active_record.initialize_database.
  Immunio::Plugin.load 'ActionRecord',
                       feature: 'sqli',
                       hooks: %w(sql_execute) do |plugin|
    require_relative "../../lib/immunio/plugins/active_record"
    plugin.loaded! ActiveRecord::VERSION::STRING
  end

  # Workaround request required for running hooks.
  require 'immunio/request'
  Immunio.agent.new_request(
    Immunio::Request.new(
      {
        "id" => 123.0,
        "test" => [
          { "plugin" => "test" },
          { "plugin" => "indeed" },
        ]
      }))
end
