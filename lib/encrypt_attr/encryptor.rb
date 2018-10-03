module EncryptAttr
  class Encryptor
    CIPHER = "AES-256-CBC".freeze

    def self.validate_secret_token(secret_token)
      return unless secret_token.size < 100

      offending_line = caller
                        .reject {|entry| entry.include?(__dir__) || entry.include?("forwardable.rb") }
                        .first[/^(.*?:\d+)/, 1]

      warn "[encrypt_attribute] secret token must have at least 100 characters (called from #{offending_line})"
    end

    def self.encrypt(secret_token, value)
      new(secret_token).encrypt(value)
    end

    def self.decrypt(secret_token, value)
      new(secret_token).decrypt(value)
    end

    # Set the encryptor's secret token.
    attr_reader :secret_token

    def initialize(secret_token)
      @secret_token = secret_token
    end

    def encrypt(value)
      encode cipher(:encrypt, value)
    end

    def decrypt(value)
      cipher(:decrypt, decode(value))
    end

    def cipher(mode, value)
      cipher = OpenSSL::Cipher.new(CIPHER).public_send(mode)
      digest = Digest::SHA256.digest(secret_token)
      cipher.key = digest
      cipher.iv = digest[0...cipher.iv_len]
      cipher.update(value) + cipher.final
    end

    def encode(value)
      Base64.encode64(value).chomp
    end

    def decode(value)
      Base64.decode64(value)
    end
  end
end
