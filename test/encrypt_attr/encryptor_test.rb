require "test_helper"

class EncryptAttrEncryptorTest < Minitest::Test
  test "encrypts value" do
    secret_token = SecureRandom.hex(50)
    encrypted = EncryptAttr::Encryptor.encrypt(secret_token, "hello")
    decrypted = EncryptAttr::Encryptor.decrypt(secret_token, encrypted)

    refute_equal "hello", encrypted
    assert_equal "hello", decrypted
  end

  test "migrates static hashed iv to a dynamic one" do
    secret_token = "25ad95bc5d407c2275c079ec4f1b138d75f91d3808c3ff8c341633c9aba150e90cedfe648a0ae7964d1808dbfc7a5e40faab"
    encrypted = "6uBcgJ9Sv1BLnkGfBnjmpQ=="

    assert_equal "hello", EncryptAttr::Encryptor.decrypt(secret_token, encrypted)

    encrypted_again = EncryptAttr::Encryptor.encrypt(secret_token, "hello")
    assert 16, encrypted_again.split(";").first.size
    assert_equal "hello", EncryptAttr::Encryptor.decrypt(secret_token, encrypted_again)

    refute_equal encrypted, encrypted_again
  end
end
