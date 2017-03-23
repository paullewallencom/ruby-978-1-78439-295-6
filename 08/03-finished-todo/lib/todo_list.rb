require 'redis'
require 'multi_json'
require 'securerandom'

module Todo
end

class Todo::TodoList
  HASH_NAME='re:08:todo_list'

  def initialize(redis_client)
    if ! (redis_client.is_a?(Redis))
      raise "Expected a Redis instance, got #{redis_client.class}"
    end

    @redis_client = redis_client
  end

  def add(text)
    id       = SecureRandom.uuid
    new_todo = {
      'id'   => id,
      'text' => text,
      'done' => false,
      'ts'   => Time.now.to_f.to_s
    }

    @redis_client.hset(HASH_NAME, id, MultiJson.encode(new_todo))

    id
  end

  def all
    @redis_client.hgetall(HASH_NAME).values.map do |s|
      MultiJson.decode(s)
    end.sort_by do |hsh|
      hsh['ts']
    end.map do |hsh|
      hsh.delete('ts')
      hsh
    end
  end

  def delete_all
    @redis_client.del(HASH_NAME)
    self.all
  end

  def toggle_done(id)
    old_val = @redis_client.hget(HASH_NAME, id)

    if (old_val)
      new_val = MultiJson.decode(old_val)
      new_val['done'] = ! new_val['done']
      @redis_client.hset(HASH_NAME, id, MultiJson.encode(new_val))
      new_val
    end
  end

  def delete_finished
    self.all.select do |hsh|
      if hsh['done']
        @redis_client.hdel(HASH_NAME, hsh['id'])
        false
      else
        true
      end
    end
  end
end