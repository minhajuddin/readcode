require 'stringio'
require 'cgi'
require 'rubygems'
require 'bundler'
Bundler.require(:default)

#clone repo
#create the html file
#create the epub file

#class Reader
#def initialize(path)
#@repo = Rugged::Repository.new(path)

#@toc = StringIO.new
#@body = StringIO.new
#end

#def render
#tree = @repo.head.target.tree
#tree.walk_blobs do |root, entry|
#begin
#obj =  @repo.lookup(entry[:oid])
#next if obj.binary? #ignore binary objects
#write(root, entry, obj)
#rescue => ex
#STDERR.puts "ERROR: writing #{root}#{entry[:name]} #{ex.inspect}"
#end
#end
#end

#def write(root, entry, obj)
#return if obj.binary?

#@toc.puts "<li><a href='##{path}'>#{path}</a></li>"
#@body.puts "<h2 id='#{path}'><a href='##{path}'>#{path}</a></h2>"
#@body.puts "<pre><code>#{CGI.escapeHTML(obj.text)}</code></pre>"
#end

#def html
#repo_name = File.basename(@repo.path.gsub("/.git/", ''))
#"<!doctype html><html><head><title>#{repo_name}</title><script src='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/highlight.min.js'></script><link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/default.min.css'><link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/monokai.min.css'><script>hljs.initHighlightingOnLoad();</script></head><body><ol>#{@toc.string}</ol><div class='body'>#{@body.string}</div></body></html>"
#end
#end

##r = Reader.new('/home/minhajuddin/r/elf')
#r = Reader.new('git://github.com/minhajuddin/timelogger')
#r.render
#puts r.html
