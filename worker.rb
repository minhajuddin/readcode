require './reader'

# Connect to pool
@beanstalk = Beaneater::Pool.new(['localhost:11300'])
# Enqueue jobs to tube
@tube = @beanstalk.tubes["readcode"]

#handle interrupts
trap 'SIGINT' do
  # Disconnect the pool
  @beanstalk.close
end
trap 'SIGTERM' do
  # Disconnect the pool
  @beanstalk.close
end


def render(path)
  #prefix the default protocol
  path = "https://" + path unless Reader::PROTOCOLRX === path

  reader = Reader.new(path)
  begin
    out = reader.export
    send_file out
  rescue => ex
    puts ex
  end
end

# Process jobs from tube
while job = @tube.reserve
  begin
    render(job)
  rescue => ex
    puts "ERROR rendering #{job.inspect} #{ex.inspect}"
  ensure
    job.delete
  end
end
