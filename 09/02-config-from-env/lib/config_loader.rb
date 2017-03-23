class ConfigLoader
  attr_reader :config, :masked_config

  def initialize(opts={})
    if ! opts['config'].is_a?(Hash)
      raise "Expected 'config' to be a Hash, got #{opts['config'].class}"
    end
    
    @config      = opts['config']
    @whitelist   = opts['whitelist'] || []
    @required    = opts['required']  || []

    self.class.check_required_keys!(@config, @required)
    
    @masked_config = self.class.mask_hash(@config, @whitelist)
  end
  
  class << self
    def check_required_keys!(hsh, required)
      missing_keys = required.select { |k| ! hsh.has_key?(k) }
    
      if ! missing_keys.empty?
        pluralized = if missing_keys.size == 1
          'key'
        else
          'keys'
        end
      
        raise "Missing required #{pluralized}: #{missing_keys.join(', ')}"
      else
        true
      end
    end
  
    def mask_hash(hsh, whitelist)
      hsh.inject({}) do |masked, (k,v)|
        masked[k] = if whitelist.include?(k)
          v
        else
          '[MASKED]'
        end
        
        masked
      end
    end
  end
end