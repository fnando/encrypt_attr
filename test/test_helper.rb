require "simplecov"
SimpleCov.start

require "bundler/setup"
require "active_record"
require "encrypt_attr"
require "minitest/autorun"
require "minitest/utils"

require_relative "./support/md5_encryptor"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.text :encrypted_api_key
  end
end
