module EncryptAttr
  module Base
    def self.included(target)
      target.extend(ClassMethods)
    end

    class << self
      # Define the object that will encrypt/decrypt values.
      # By default, it's EncryptAttr::Encryptor
      attr_accessor :encryptor
    end

    def self.secret_token
      @secret_token
    end

    def self.secret_token=(secret_token)
      validate_secret_token(secret_token.to_s)
      @secret_token = secret_token.to_s
    end

    def self.validate_secret_token(secret_token)
      if secret_token.size < 100
        offending_line = caller
                          .reject {|entry| entry.include?(__dir__) || entry.include?('forwardable.rb') }
                          .first[/^(.*?:\d+)/, 1]
        warn "[encrypt_attribute] secret token must have at least 100 characters (called from #{offending_line})"
      end
    end

    # Set initial token value to empty string.
    # Cannot assign through writer method because of size warning.
    @secret_token = ''

    # Set initial encryptor engine.
    self.encryptor = Encryptor

    module ClassMethods
      def encrypt_attr(*args, secret_token: EncryptAttr.secret_token)
        EncryptAttr.validate_secret_token(secret_token)

        args.each do |attribute|
          define_encrypted_attribute(attribute, secret_token)
        end
      end
      alias_method :attr_encrypt, :encrypt_attr
      alias_method :attr_encrypted, :encrypt_attr
      alias_method :attr_vault, :encrypt_attr
      alias_method :encrypt_attr, :encrypt_attr
      alias_method :encrypt_attribute, :encrypt_attr
      alias_method :encrypted_attr, :encrypt_attr
      alias_method :encrypted_attribute, :encrypt_attr

      private

      def define_encrypted_attribute(attribute, secret_token)
        define_method attribute do
          instance_variable_get("@#{attribute}")
        end

        define_method "#{attribute}=" do |value|
          instance_variable_set("@#{attribute}", value)
          send("encrypted_#{attribute}=", nil)
          send("encrypted_#{attribute}=", EncryptAttr.encryptor.encrypt(secret_token, value)) if value
        end
      end
    end
  end
end
