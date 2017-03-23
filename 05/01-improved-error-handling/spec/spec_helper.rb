require 'rspec'
require 'webmock/rspec'

require_relative 'config/redis'
require_relative 'config/vcr'

RSpec.configure do |config|
  if ENV['ALLOW_NET_CONNECT']
    WebMock.allow_net_connect!
  else
    WebMock.disable_net_connect!
  end
  
  config.order            = 'random'
  config.profile_examples = 1
  config.color            = true
end
