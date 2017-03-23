require 'pp'

config = {
  'RE09_TODO_STORE'     => ENV['RE09_TODO_STORE'],
  'RE09_REDIS_URL'      => ENV['RE09_REDIS_URL'],
  'RE09_REDIS_PASSWORD' => ENV['RE09_REDIS_PASSWORD']
}

pp config

puts
puts "App would start here..."

exit 0