require 'minitest_helper'

describe EncryptAttr do
  it 'warns about short secret token (global)' do
    line_number = __LINE__ + 3

    out, err = capture_io do
      EncryptAttr.secret_token = 'short'
    end

    expected_message = [
      '[encrypt_attribute] secret token must have at least 100 characters',
      "(called from #{__FILE__}:%d)"
    ].join(' ')

    err.must_include(expected_message % line_number)
  end

  it 'warns about short secret token (attribute)' do
    line_number = __LINE__ + 5

    out, err = capture_io do
      create_class {
        attr_accessor :encrypted_api_key
        attr_vault :api_key, secret_token: 'short'
      }
    end

    expected_message = [
      '[encrypt_attribute] secret token must have at least 100 characters',
      "(called from #{__FILE__}:%d)"
    ].join(' ')

    err.must_include(expected_message % line_number)
  end

  %w[
    attr_encrypt
    attr_encrypted
    attr_vault
    encrypt_attribute
    encrypted_attr
    encrypted_attribute
  ].each do |encryption_method|
    it "encrypts attribute using alias method - #{encryption_method}" do
      EncryptAttr.secret_token = SecureRandom.hex(50)
      encrypted_api_key = EncryptAttr::Encryptor
                          .encrypt(EncryptAttr.secret_token, 'API_KEY')

      klass = create_class do
        attr_accessor :encrypted_api_key
        send encryption_method, :api_key
      end

      instance = klass.new(api_key: 'API_KEY')
      instance.api_key = 'API_KEY'
      instance.encrypted_api_key.must_equal(encrypted_api_key)
    end
  end

  it 'encrypts one attribute using default secret token' do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    encrypted_api_key = EncryptAttr::Encryptor
                        .encrypt(EncryptAttr.secret_token, 'API_KEY')

    klass = create_class do
      attr_accessor :encrypted_api_key
      encrypt_attr :api_key
    end

    instance = klass.new(api_key: 'API_KEY')

    instance.api_key.must_equal('API_KEY')
    instance.encrypted_api_key.wont_be_nil
    instance.encrypted_api_key.must_equal(encrypted_api_key)
  end

  it 'encrypts one attribute using custom secret token' do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    custom_secret_token = SecureRandom.hex(50)
    encrypted_api_key = EncryptAttr::Encryptor
                        .encrypt(custom_secret_token, 'API_KEY')

    klass = create_class do
      attr_accessor :encrypted_api_key
      encrypt_attr :api_key, secret_token: custom_secret_token
    end

    instance = klass.new(api_key: 'API_KEY')

    instance.encrypted_api_key.must_equal(encrypted_api_key)
  end

  it 'encrypts multiple attributes using default secret token' do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    encrypted_api_key = EncryptAttr::Encryptor
                        .encrypt(EncryptAttr.secret_token, 'API_KEY')

    encrypted_api_client_id = EncryptAttr::Encryptor
                              .encrypt(EncryptAttr.secret_token, 'API_CLIENT_ID')

    klass = create_class do
      attr_accessor :encrypted_api_key, :encrypted_api_client_id
      encrypt_attr :api_key, :api_client_id
    end

    instance = klass.new(api_key: 'API_KEY', api_client_id: 'API_CLIENT_ID')

    instance.api_key.must_equal('API_KEY')
    instance.api_client_id.must_equal('API_CLIENT_ID')

    instance.encrypted_api_key.must_equal(encrypted_api_key)
    instance.encrypted_api_client_id.must_equal(encrypted_api_client_id)
  end

  it 'encrypts multiple attributes using custom secret token' do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    custom_secret_token = SecureRandom.hex(50)
    encrypted_api_key = EncryptAttr::Encryptor
                        .encrypt(custom_secret_token, 'API_KEY')

    encrypted_api_client_id = EncryptAttr::Encryptor
                              .encrypt(custom_secret_token, 'API_CLIENT_ID')

    klass = create_class do
      attr_accessor :encrypted_api_key, :encrypted_api_client_id
      encrypt_attr :api_key, :api_client_id, secret_token: custom_secret_token
    end

    instance = klass.new(api_key: 'API_KEY', api_client_id: 'API_CLIENT_ID')

    instance.encrypted_api_key.must_equal(encrypted_api_key)
    instance.encrypted_api_client_id.must_equal(encrypted_api_client_id)
  end

  it 'updates encrypted value' do
    EncryptAttr.secret_token = SecureRandom.hex(50)

    klass = create_class do
      attr_accessor :encrypted_api_key
      encrypt_attr :api_key
    end

    instance = klass.new(api_key: 'API_KEY')
    encrypted_api_key = instance.encrypted_api_key

    instance.api_key = 'NEW_API_KEY'

    instance.api_key.must_equal('NEW_API_KEY')

    EncryptAttr::Encryptor.decrypt(
      EncryptAttr.secret_token, instance.encrypted_api_key
    ).must_equal('NEW_API_KEY')
  end

  it 'skips nil values' do
    klass = create_class do
      attr_accessor :encrypted_api_key
      encrypt_attr :api_key
    end

    instance = klass.new(api_key: 'API_KEY')
    instance.api_key = nil
    instance.api_key.must_be_nil
    instance.encrypted_api_key.must_be_nil
  end

  def create_class(&block)
    Class.new {
      include EncryptAttr
      instance_eval(&block)

      def initialize(options = {})
        options.each {|k, v| public_send("#{k}=", v) }
      end
    }
  end
end
