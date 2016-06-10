require 'rubygems'
require 'sinatra'
require 'awesome_print'
require 'haml'
require 'json'
require "erb"

require "./lib/user.rb"
require "./lib/bot.rb"
require "./lib/setting.rb"

ActiveRecord::Base.establish_connection(Setting.config["database"])

class Messenger < Sinatra::Base
  set :haml, :format => :html5

  get '/' do
    erb :index
  end

  get '/receive' do
    if params["hub.verify_token"] == "secret_pass"
      params["hub.challenge"]
    else
      "403"
    end
  end

  post '/receive' do
    request.body.rewind
    messenger_params = JSON.parse(request.body.read)
    ap messenger_params

    Bot::handle_messages(messenger_params)

    "200 - Ok"
  end
end