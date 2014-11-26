require 'stringio'
require 'cgi'
require 'rugged'
require 'pygments'
require 'tempfile'

class Reader
  attr_reader :remote_path, :dir, :repo

  PUBLIC_DIR = File.dirname(File.expand_path(__FILE__))

  def initialize(remote_path)
    @remote_path = remote_path
    @dir = Dir.mktmpdir('readcode')
    filepath = @remote_path.gsub(%r{^(git|http|https)://},'').gsub('/', '.') + ".html"
    @toc = File.open(File.join(PUBLIC_DIR, filepath + ".toc"), "w")
    @code = File.open(File.join(PUBLIC_DIR, filepath + ".code"), "w")
  end

  def export
    clone
    render
    write
  end

  private
  def clone
    puts "cloning #@remote_path in #@dir"
    @repo = Rugged::Repository.clone_at(@remote_path, @dir)
    @master = @repo.head.target.tree
  end

  def write
  end

  def render
    puts "rendering"

    #write all trees recursively
    write_tree @master

    puts "done"
  end

  def write_tree(tree)
    @toc.write "<ul>"
    #write all the blobs first
    tree.each_blob do |b|
      write_blob b
    end

    #recursively write all the trees
    tree.each_tree do |t|
      write_tree t
    end
    @toc.write "</ul>"
  end

  def write_blob(blob)
    obj =  @repo.lookup(blob[:oid])
    @toc.write "<li>#{blob[:name]} #{"[binary]" if obj.binary?}</li>"
    return if obj.binary? #ignore binary objects

    @code.puts "<pre><code>#{CGI.escapeHTML(obj.text)}</code></pre>"
  end

end
