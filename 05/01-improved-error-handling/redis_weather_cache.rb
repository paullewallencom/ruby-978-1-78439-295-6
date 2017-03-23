require 'redis'

module RedisWeatherCache
  CACHE_KEY             = 'weather_query:cache'
  EXPIRY_ZSET_KEY       = 'weather_query:expiry_tracker'
  EXPIRE_FORECAST_AFTER = 300 # 5 minutes   

  class << self
    def redis_client
      if ! defined?(::REDIS_CLIENT)
        raise("No REDIS_CLIENT defined!")
      end
      
      ::REDIS_CLIENT
    end
    
    def []=(location, forecast)
      redis_client.hset(CACHE_KEY, location, JSON.generate(forecast))
      redis_client.zadd(EXPIRY_ZSET_KEY, Time.now.to_i, location)
    end
    
    def [](location)
      remove_expired_entries
      
      raw_value = redis_client.hget(CACHE_KEY, location)
      
      if raw_value
        JSON.parse(raw_value)
      else
        nil
      end
    end
    
    def all
      redis_client.hgetall(CACHE_KEY).inject({}) do |memo, (location, forecast_json)|
        memo[location] = JSON.parse(forecast_json)
        memo
      end
    end
    
    def clear!
      redis_client.del(CACHE_KEY)
    end
    
    def remove_expired_entries
      # expired locations have a score, i.e. creation timestamp, less than a certain threshold
      expired_locations = redis_client.zrangebyscore(EXPIRY_ZSET_KEY, 0, Time.now.to_i - EXPIRE_FORECAST_AFTER)

      if ! expired_locations.empty?
        # remove the cache entry
        redis_client.hdel(CACHE_KEY, expired_locations)            

        # also clear the expiry entry
        redis_client.zrem(EXPIRY_ZSET_KEY, expired_locations)  
      end
    end
  end
end