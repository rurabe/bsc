uri = URI.parse("redis://rediscloud:XSB0vrM7HZRMOuHW@pub-redis-19203.us-east-1-1.2.ec2.garantiadata.com:19203")
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)