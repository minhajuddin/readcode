@beanstalk = Beaneater::Pool.new(['localhost:11300'])
# Enqueue jobs to tube
@tube = @beanstalk.tubes["readcode"]

#display the home page
get '/' do
  if params.key?("repo")
    redirect to("/r/#{params['repo']}")
    return
  end

  erb :index
end

#trigger repo render
get '/r/*' do
  repo = params[:splat].first.to_s
  return erb(:error) if repo.include?("..")
  #TODO add validations on path to avoid getting pwned
  #if the code reaches this, it means there is no cache
  @tube.put repo

  @path = request.path_info
  erb :rendering
end

#TODO refresh action
