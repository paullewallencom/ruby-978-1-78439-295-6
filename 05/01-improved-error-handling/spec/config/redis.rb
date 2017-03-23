require 'rspec'
require 'redis'

ENV['WQ_REDIS_URL'] ||= 'redis://localhost:6379/15'

RSpec.configure do |config|
  if ! ENV['WQ_REDIS_URL'].is_a?(String)
    raise "WQ_REDIS_URL environment variable not set"
  end

  ::REDIS_CLIENT = Redis.new( :url => ENV['WQ_REDIS_URL'] )

  config.after(:example, :redis) do    
    ::REDIS_CLIENT.flushdb
  end
end