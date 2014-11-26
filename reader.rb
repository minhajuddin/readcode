require 'stringio'
require 'cgi'
require 'rugged'
require 'pygments'
require 'tempfile'

class Reader
  attr_reader :remote_path, :dir, :repo, :outpath

  PUBLIC_DIR = "/tmp"
  #PUBLIC_DIR = File.dirname(File.expand_path(__FILE__))
  HEADER = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "header.html"))
  FOOTER = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "footer.html"))

  def initialize(remote_path)
    @remote_path = remote_path
    @dir = Dir.mktmpdir('readcode')
    @name = @remote_path.gsub(%r{^(git|http|https)://},'')
    @filepath = @name.gsub('/', '.') + ".html"
    @toc = Tempfile.new(@filepath + ".code")
    @code = Tempfile.new(@filepath + ".code")
    @outpath = File.join(PUBLIC_DIR, @filepath)
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
    File.open(@outpath, "w") do |f|
      #write header
      f.write HEADER.gsub("REPONAME", @name)
      #write toc
      @toc.rewind
      @toc.each_line do |l|
        f.write l
      end
      #write code
      @code.rewind
      @code.each_line do |l|
        f.write l
      end
      #write footer
      f.write FOOTER.gsub("REPONAME", @name)
    end

    @toc.unlink
    @code.unlink
  end

  def render
    puts "rendering"

    #write all trees recursively
    write_tree @master

    puts "rendering done"
  end

  def write_tree(tree)
    @toc.puts "<ul>"
    #write all the blobs first
    tree.each_blob do |b|
      write_blob tree, b
    end

    #recursively write all the trees
    tree.each_tree do |t|
      write_tree @repo.lookup(t[:oid])
    end
    @toc.puts "</ul>"
  end

  def write_blob(tree, blob)
    obj =  @repo.lookup(blob[:oid])
    name = blob[:name]
    @toc.write "<li>#{name}#{" [binary]" if obj.binary?}</li>"
    return if obj.binary? #ignore binary objects


    @code.puts "<h3 id='#{name}'><a href='##{name}'>#{name}</a></h3>"
    @code.puts "<pre><code>#{CGI.escapeHTML(obj.text)}</code></pre>"
  end

end
