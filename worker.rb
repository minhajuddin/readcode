require 'bundler'
Bundler.require(:default)
require './reader'

# Connect to pool
@beanstalk = Beaneater::Pool.new(['localhost:11300'])
# Enqueue jobs to tube
@tube = @beanstalk.tubes["readcode"]

@listen = true
def close
  puts "received interrupt"
  @listen = false
  # Disconnect the pool
  puts 'closing beanstalk'
  @beanstalk.close
  exit
end

#handle interrupts
trap 'SIGINT' do
  close
end
trap 'SIGTERM' do
  close
end


def render(path)
  #prefix the default protocol
  path = "https://" + path unless Reader::PROTOCOLRX === path

  reader = Reader.new(path)
  begin
    reader.export
  rescue => ex
    puts ex
  end
end

puts "listening for jobs"
# Process jobs from tube
while @listen
  begin
    job = @tube.reserve(1)
  rescue Beaneater::TimedOutError
    next
  end
  begin
    render(job.body)
  rescue => ex
    puts "ERROR rendering #{job.inspect} #{ex.inspect}"
  ensure
    job.delete
  end
end
