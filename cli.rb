require 'bundler'
Bundler.require(:default)
require './reader'

reader = Reader.new("git://github.com/minhajuddin/readcode")
reader.export

puts reader.outpath
