require 'stringio'
require 'cgi'
class Repo
  attr_reader :path

  def initialize(path)
    @path = path
  end
end
