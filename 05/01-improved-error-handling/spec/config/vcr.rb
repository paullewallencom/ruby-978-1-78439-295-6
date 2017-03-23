if ENV['ALLOW_NET_CONNECT']
  VCR_RECORD_MODE='irrelevant'
else
  require 'vcr'

  VCR_RECORD_MODE = (ENV['VCR_RECORD_MODE'] || :none).to_sym

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/cassettes'
    c.hook_into :webmock
    c.configure_rspec_metadata!
  end
end