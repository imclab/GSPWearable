require 'sinatra'
require 'json'

get '/' do
    content_type :json

    puts "blink"

    { :blink => 'true' }.to_json
end