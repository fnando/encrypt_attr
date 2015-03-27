require 'encrypt_attr'
ActiveRecord::Base.send :include, EncryptAttr::Base
