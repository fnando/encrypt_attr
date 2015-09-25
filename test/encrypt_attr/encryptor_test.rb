require 'minitest_helper'

class EncryptAttrEncryptorTest < Minitest::Test
  test 'encrypts value' do
    secret_token = SecureRandom.hex(50)
    encrypted = EncryptAttr::Encryptor.encrypt(secret_token, 'hello')
    decrypted = EncryptAttr::Encryptor.decrypt(secret_token, encrypted)

    refute_equal 'hello', encrypted
    assert_equal 'hello', decrypted
  end
end
