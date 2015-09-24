# EncryptAttr

[![Build Status](https://travis-ci.org/fnando/encrypt_attr.svg)](https://travis-ci.org/fnando/encrypt_attr)
[![Code Climate](https://codeclimate.com/github/fnando/encrypt_attr/badges/gpa.svg)](https://codeclimate.com/github/fnando/encrypt_attr)
[![Test Coverage](https://codeclimate.com/github/fnando/encrypt_attr/badges/coverage.svg)](https://codeclimate.com/github/fnando/encrypt_attr)

Encrypt attributes using AES-256-CBC (or your custom encryption strategy). Works with and without ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encrypt_attr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encrypt_attr

## Usage

The most basic usage is including the `EncryptAttr` module.

```ruby
class User
  include EncryptAttr
  attr_accessor :encrypted_api_key
  encrypt_attr :api_key
end
```

The `encrypt_attr` method has some aliases, so you can also use any of these:

- `attr_encrypt`
- `attr_encrypted`
- `attr_vault`
- `encrypt_attr`
- `encrypt_attribute`
- `encrypted_attr`
- `encrypted_attribute`

This assumes that you have a `encrypted_api_key` attribute. By default, the value is encrypted using a global secret token. You can set a custom token by setting `EncryptAttr.secret_token`; you have to use 100 characters or more (e.g. `$ openssl rand -hex 50`).

```ruby
EncryptAttr.secret_token = 'abc123'
```

You can also set the secret token per attribute basis.

```ruby
class User
  include EncryptAttr
  attr_accessor :encrypted_api_key
  encrypt_attr :api_key, secret_token: USER_SECRET_TOKEN
end
```

To access the decrypted value, just use the method with the same name.

```ruby
user = User.new
user.api_key = 'abc123'
user.api_key                #=> abc123
user.encrypted_api_key      #=> UcnhbnAl1Rmvt1mkG0m1FA...

user.api_key = 'newsecret'
user.api_key                #=> newsecret
user.encrypted_api_key      #=> JgH5dFGl8HnJNEloXZ6qSg...
```

You encrypt multiple attributes at once.

```ruby
class User
  include EncryptAttr
  attr_accessor :encrypted_api_key
  encrypt_attr :api_key, :api_client_id
end
```

### ActiveRecord integration

You can also use encrypted attributes with ActiveRecord. If ActiveRecord is available, it's included automatically. You can also manually include `EncryptAttr::Base` or require `encrypt_attr/activerecord`.

```ruby
class User < ActiveRecord::Base
  encrypt_attr :api_key
end
```

The usage is pretty much the same, and you can set a secret for each attribute. The example above will require a column name `encrypted_api_key`.

```ruby
class AddEncryptedApiKeyToUsers < ActiveRecord::Base
  def change
    add_column :users, :encrypted_api_key, :text, null: false
  end
end
```

### Using a custom encryption

You can define your encryption engine by defining an object that responds to `encrypt(secret_token, value)` and `decrypt(secret_token, value)`. Here's an example:

```ruby
module ReverseEncryptor
  def self.encrypt(secret_token, value)
    value.to_s.reverse
  end

  def self.decrypt(secret_token, value)
    value.to_s.reverse
  end
end

EncryptAttr.encryptor = ReverseEncryptor

class User
  include EncryptAttr
  attr_accessor :encrypted_api_key
  attr_encrypted :api_key
end

user = User.new
user.api_key = 'API_KEY'
user.encrypted_api_key #=> 'YEK_IPA'
```

You can also specify a custom encryptor per attribute.

```ruby
class User
  include EncryptAttr
  attr_accessor :encrypted_api_key
  attr_encrypted :api_key, encryptor: ReverseEncryptor
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/fnando/encrypt_attr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
