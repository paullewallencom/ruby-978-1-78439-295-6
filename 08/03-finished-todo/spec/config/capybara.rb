require 'capybara/rspec'

Capybara.default_driver = :selenium
    
if ENV['APP_HOST'] == 'local'
  puts 'Booting a local server using config.ru...'
  
  # use config.ru to boot the rack app
  config_ru    = File.expand_path('../../../config.ru', __FILE__)
  Capybara.app = Rack::Builder.parse_file(config_ru).first   
else
  # configure Capybara
  DEFAULT_APP_HOST    = 'http://localhost:9292'

  Capybara.run_server = false
  Capybara.app_host   = ENV['APP_HOST'] || DEFAULT_APP_HOST  
end