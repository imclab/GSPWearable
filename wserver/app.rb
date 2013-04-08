require 'sinatra'
require 'sinatra/partial'
require 'sinatra/reloader' if development?
require 'redis'
require 'json'

configure do
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri) 
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

REDIS.set('color','red')

get '/' do
    content_type :json

    puts "blink!"

    { :color => REDIS.get('color') }.to_json
end

get '/red' do
	REDIS.set('color','red')
	"red"
end

get '/green' do
	REDIS.set('color','green')
	"green"
end

get '/blue' do
	REDIS.set('color','blue')
	"blue"
end