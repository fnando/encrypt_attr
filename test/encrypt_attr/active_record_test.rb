require "test_helper"

class EncryptAttrActiveRecordTest < Minitest::Test
  test "includes module" do
    assert_includes ActiveRecord::Base.included_modules, EncryptAttr::Base
  end

  test "encrypts attributes" do
    EncryptAttr.secret_token = SecureRandom.hex(50)
    model = Class.new(ActiveRecord::Base) {
      self.table_name = "users"
      encrypt_attr :api_key
    }

    encrypted_api_key = EncryptAttr::Encryptor
                          .encrypt(EncryptAttr.secret_token, "API_KEY")

    instance = model.create(api_key: "API_KEY")
    instance = model.last

    assert_equal encrypted_api_key, instance.encrypted_api_key
    assert_equal "API_KEY", instance.api_key
  end
end
