#!/usr/bin/env ruby

require_relative 'redis_weather_query'
require 'json'

REDIS_CLIENT = Redis.new

if ARGV.size == 0
  abort "usage: #{__FILE__} <location>"
end

location  = ARGV.join(" ")
response  = RedisWeatherQuery.forecast(location)
formatted = JSON.pretty_generate(response)

puts formatted

exit 0
