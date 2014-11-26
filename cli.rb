require 'bundler'
Bundler.setup(:default)
require './reader'

reader = Reader.new("git://github.com/minhajuddin/readcode")
reader.export

puts reader.outpath
