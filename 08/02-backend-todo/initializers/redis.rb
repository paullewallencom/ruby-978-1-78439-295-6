require 'redis'

ENV['REDIS_URL'] ||= 'redis://localhost:6379/15'

if ! ENV['REDIS_URL'].is_a?(String)
  raise "REDIS_URL environment variable not set"
end

::REDIS_CLIENT = Redis.new( :url => ENV['REDIS_URL'] )