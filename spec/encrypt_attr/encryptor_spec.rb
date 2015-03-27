require 'minitest_helper'

describe EncryptAttr::Encryptor do
  it 'encrypts value' do
    secret_token = SecureRandom.hex(50)
    encrypted = EncryptAttr::Encryptor.encrypt(secret_token, 'hello')
    decrypted = EncryptAttr::Encryptor.decrypt(secret_token, encrypted)

    encrypted.wont_equal('hello')
    decrypted.must_equal('hello')
  end
end
