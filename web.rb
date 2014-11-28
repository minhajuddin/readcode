beanstalk = Beaneater::Pool.new(['localhost:11300'])
# Enqueue jobs to tube
$tube = beanstalk.tubes["readcode"]

#display the home page
get '/*' do

  #if it was a form submission redirect
  #to the canonical path
  if params.key?('repo')
    redirect to("/#{params['repo']}")
    return
  end

  repo = params[:splat].first

  return erb(:index) if repo.to_s.empty?

  #TODO add validations on path to avoid getting pwned
  return erb(:error) if repo.include?("..")

  #if the code reaches this, it means there is no cache
  #enque it on beanstalk and let the worker take care of it
  $tube.put repo

  @path = request.path_info
  erb(:rendering)
end

#TODO refresh action
