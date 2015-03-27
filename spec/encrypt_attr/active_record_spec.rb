require 'minitest_helper'

describe EncryptAttr, 'ActiveRecord support' do
  it 'includes module' do
    ActiveRecord::Base.included_modules.must_include(EncryptAttr::Base)
  end

  it 'encrypts attributes' do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    model = Class.new(ActiveRecord::Base) {
      self.table_name = 'users'
      encrypt_attr :api_key
    }

    encrypted_api_key = EncryptAttr::Encryptor
                          .encrypt(EncryptAttr.secret_token, 'API_KEY')

    instance = model.create(api_key: 'API_KEY')
    instance.reload

    instance.encrypted_api_key.must_equal(encrypted_api_key)
    instance.api_key.must_equal('API_KEY')
  end
end
