require "../spec_helper"

protected def redis
  redis_cluster_client
end

protected def sort(a)
  unless a.is_a? Array(Redis::RedisValue)
    raise "Cannot sort this: #{a.class}"
  end

  a.map(&.to_s).sort!
end

# Same as `sort` except sorting feature
protected def array(a) : Array(String)
  (a.as(Array(Redis::RedisValue))).map(&.to_s)
rescue
  raise "Cannot convert to Array(Redis::RedisValue): #{a.class}"
end
