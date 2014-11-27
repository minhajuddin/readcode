require 'bundler'
Bundler.require(:default, :web)
require './web'

run Sinatra::Application
