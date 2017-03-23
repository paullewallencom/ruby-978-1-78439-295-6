require 'pp'

config = {
  'TODO_STORE'     => ENV['TODO_STORE'],
  'REDIS_URL'      => ENV['REDIS_URL'],
  'REDIS_PASSWORD' => ENV['REDIS_PASSWORD']
}

pp config

puts
puts "App would start here..."

exit 0