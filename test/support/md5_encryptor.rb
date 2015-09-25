require 'digest/md5'

class MD5Encryptor
  def self.encrypt(_, value)
    Digest::MD5.hexdigest(value.to_s)
  end

  def self.decrypt(_, value)
    value.to_s
  end
end
