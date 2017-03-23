require 'rspec'
require 'webmock/rspec'

require_relative 'config/redis'

RSpec.configure do |config|
  WebMock.disable_net_connect!
  
  config.order            = 'random'
  config.profile_examples = 1
  config.color            = true
end
