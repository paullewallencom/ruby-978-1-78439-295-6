require 'rspec'

# require the webmock gem
require 'webmock/rspec'

RSpec.configure do |config|
  # this is done by default, but let's make it clear
  WebMock.disable_net_connect!
  
  config.order            = 'random'
  config.profile_examples = 1
  config.color            = true
end
