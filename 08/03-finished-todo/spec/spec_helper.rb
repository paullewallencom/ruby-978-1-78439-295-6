require 'rspec'
require_relative 'config/common'
require_relative '../initializers/redis'

RSpec.configure do |config|
  if ! defined?(::REDIS_CLIENT)
    raise("No REDIS_CLIENT defined!")
  end

  config.before(:example, :redis) do
    ::REDIS_CLIENT.flushdb
  end

  config.after(:example, :redis) do
    ::REDIS_CLIENT.flushdb
  end
end