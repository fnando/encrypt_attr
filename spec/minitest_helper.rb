require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'bundler/setup'
require 'active_record'
require 'encrypt_attr'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/utils'

require_relative './support/md5_encryptor'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.text :encrypted_api_key
  end
end

EncryptAttr.secret_token = SecureRandom.hex(50)
