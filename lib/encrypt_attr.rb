require 'forwardable'

module EncryptAttr
  require 'encrypt_attr/version'
  require 'encrypt_attr/encryptor'
  require 'encrypt_attr/base'
  require 'encrypt_attr/active_record' if defined?(ActiveRecord)

  class << self
    extend Forwardable
    def_delegators Base,  :secret_token, :secret_token=,
                          :encryptor, :encryptor=,
                          :validate_secret_token
  end

  def self.included(target)
    target.send :include, Base
  end
end
