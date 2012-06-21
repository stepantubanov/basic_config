# BasicConfig [![Build Status](https://secure.travis-ci.org/stephan778/basic_config.png)](http://travis-ci.org/stephan778/basic_config)

Friendly configuration wrapper. If you find yourself using things like:

```ruby
AppConfig = YAML.load_file('config/app.yml')[environment].symbolize_keys
```

then you might like this.

## Installation

Add this line to your application's Gemfile:

    gem 'basic_config'

And then execute:

    $ bundle

Or install it via RubyGems as:

    $ gem install basic_config

## Usage

```ruby
# Loading config is simple
settings = BasicConfig.load_file('config.yml')
# It's a simple variable, you can create as many as you like.
# You can use constants for convinience:
AppConfig = BasicConfig.load_file('config/app.yml')
DatabaseConfig = BasicConfig.load_file('config/database.yml')

# Access your configuration with simple method calls
settings.some_param

# At any level of nesting
settings.smtp.address

# Hash access also works
settings[:smtp][:address]

# And you can check if particular key exists
puts('Yes') if settings.include?(:smtp)
```

If your file has sections for different environments:
```
development:
  host: localhost
  port: 123
test:
  host: localhost
  port: 456
```
then you can load the right environment with `load_env`:
```ruby
AppConfig = BasicConfig.load_env('config.yml', Rails.env)
```

## Why should I use it instead of plain Hash variables?

### It raises errors when you unintentionally read non-existent keys

If you are using a `Hash`:
```ruby
secret_token = AppConfig[:something]
```
and for some reason your configuration does not have `:something` in it (or you
make a typo) - you'll get a `nil`. Worst case: this `nil` will live inside your system compromising
or corrupting some data until you finally notice and track it down back to this line.

If you are using a `BasicConfig`:
```ruby
AppConfig = BasicConfig.load_env('config/application.yml', 'development')
secret_token = AppConfig.something
```
you'll get `BasicConfig::NotFound` exception with a message similar to this:
    
    Configuration key 'development.something' is missing in config/application.yml

if you're constructing BasicConfig with `new`, then it'll show source code
location where BasicConfig is initialized.

```ruby
# Let's say this is config.rb, line 7:
AppConfig = BasicConfig.new({ secret_token: 'something' })

# And this is somewhere in some method in another file:
secret_token = AppConfig.secret_toklen # Note a typo here
# Above line will result in BasicConfig::NotFound exception with message:
# Configuration key 'secret_toklen' is missing in BasicConfig constructed at config.rb:7 in `method'
```

*Note:* There is also an `include?` method which you can use to check if
particular key exist in your config - `AppConfig.include?(:something)`.
Additionaly, for some keys it makes sense to get a `nil` when they do not exist and for this
purpose there is a `[]` method which is delegated to underlying hash.

### Works recursively

If your YAML is more than 1 level deep then simple `symbolize_keys` is not going to be enough:
```ruby
AppConfig[:something]['have_to_use_string_here']
```

With BasicConfig above would look like this:
```ruby
AppConfig.something.have_to_use_string_here
```

### Easier to test

You can stub out any config variable just like a normal method in your tests.

```ruby
AppConfig.stub(:something).and_return('anything')
```

## Gotchas

The only thing that I can think of is be aware that you can not use Ruby Object
method names for your configuration variable names (`puts`, `print`, `raise`,
`display`, etc, you can see the full list with `BasicConfig.methods`).
