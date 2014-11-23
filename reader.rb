require 'stringio'
require 'cgi'
require 'rubygems'
require 'bundler'
Bundler.require(:default)

class Reader
  def initialize(path)
    @repo = Rugged::Repository.new(path)
    @toc = StringIO.new
    @body = StringIO.new
    @linguist = Linguist::Repository.new(@repo, @repo.head.target_id)
    @file_languages = @linguist.breakdown_by_file.map do|lang, files|
      files.map.each do|f|
        lang = Linguist::Language::find_by_name("Ruby")
        lang = lang ? lang.default_alias_name : "nohighlight"
        [f, lang]
      end
    end.flatten(1).to_h
  end

  def render
    @repo.head.target.tree.walk_blobs do |root, entry|
      obj =  @repo.lookup(entry[:oid])
      write("#{root}#{entry[:name]}", obj.text) if !obj.binary?
    end
  end

  def write(path, text)
    lang = @file_languages[path]
    @toc.puts "<li><a href='##{path}'>#{path}</a></li>"
    @body.puts "<h2 id='#{path}'><a href='##{path}'>#{path}</a></h2>"
    @body.puts "<pre><code class='#{lang}'>#{CGI.escapeHTML(text)}</code></pre>"
  end

  def html
    repo_name = File.basename(@repo.path.gsub("/.git/", ''))
    "<!doctype html><html><head><title>#{repo_name}</title><script src='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/highlight.min.js'></script><link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/default.min.css'><link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.4/styles/monokai.min.css'><script>hljs.initHighlightingOnLoad();</script></head><body><ol>#{@toc.string}</ol><div class='body'>#{@body.string}</div></body></html>"
  end
end

r = Reader.new('/home/minhajuddin/gocode/src/github.com/minhajuddin/timelogger')
r.render
puts r.html


