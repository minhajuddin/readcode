require 'bundler'
Bundler.require(:default, :web)
require './reader'

get '/' do
  if params.key?("repo")
    redirect to("/r/#{params['repo']}")
    return
  end

  erb :index
end

get '/r/*' do
  repo_path = params[:splat].first
  repo_path = "https://" + repo_path unless Reader::PROTOCOLRX === repo_path
  reader = Reader.new(repo_path)
  begin
    out = reader.export
    send_file out
  rescue => ex
    puts ex
  end
end

run Sinatra::Application
