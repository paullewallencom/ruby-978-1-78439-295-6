require_relative 'lib/config_loader'
require_relative 'lib/config_rack_app'

begin
  # find this app's config's, which all start with RE09_
  raw_configs = ENV.to_hash.select do |k, v|
    k =~ /^RE09_/
  end

  # read the list of whitelisted and required configs
  whitelist = File.read('config/.whitelist').split("\n")
  required  = File.read('config/.required').split("\n")

  loader = ConfigLoader.new({
    'config'    => raw_configs,
    'required'  => required,
    'whitelist' => whitelist
  })

  module TodoApp
  end

  TodoApp::CONFIG          = loader.config
  TodoApp::CONFIG_RACK_APP = ConfigRackApp.new(loader.masked_config)  

rescue
  msg = "Error loading configuration"
  msg << "\n  "
  msg << $!.message

  abort msg
end




