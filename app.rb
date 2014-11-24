require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './repo'

get '/' do
  puts params.inspect
  if params.key?("repo")
    redirect to("/r/#{params['repo']}")
    return
  end

  erb :index
end

get '/r/*' do
  repo_path = params[:splat].first
  @repo = Repo.new(repo_path)
  erb :repo
end
