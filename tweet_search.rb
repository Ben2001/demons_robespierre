require 'twitter'
require 'redis'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

counter = 0
client.filter(:track => "operobespierre", :lang => "fr") do |object|
  if object.is_a?(Twitter::Tweet)
    counter += 1
    REDIS.set "robonova:tweet:#{counter}", {author_name: object.user[:name], status: object.text, profile_image_url: object.user.profile_image_url.to_s}.to_json
    REDIS.save
  end
  if counter >= ENV['TWEET_LIMIT'].to_i
    counter = 0
  end
end
