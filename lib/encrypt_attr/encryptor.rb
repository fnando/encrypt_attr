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
      cipher = OpenSSL::Cipher.new(CIPHER).encrypt
      key = Digest::SHA256.digest(secret_token)
      iv = SecureRandom.random_bytes(cipher.iv_len).unpack("H*").first[0...cipher.iv_len]

      cipher.key = key
      cipher.iv = iv

      iv + ";" + encode(cipher.update(value) + cipher.final)
    end

    def decrypt(value)
      cipher = OpenSSL::Cipher.new(CIPHER).decrypt
      key = Digest::SHA256.digest(secret_token)

      parts = value.split(";")

      if parts.size == 1
        value = decode(value)
        iv = key[0...cipher.iv_len]
      else
        iv = parts.first
        value = decode(parts.last)
      end

      cipher.key = key
      cipher.iv = iv

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
