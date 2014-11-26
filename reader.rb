require 'stringio'
require 'cgi'
require 'tempfile'

class Reader
  PROTOCOLRX = %r{^(git|http|https)://}
  attr_reader :remote_path, :dir, :repo, :outpath

  PUBLIC_DIR = File.join(File.dirname(File.expand_path(__FILE__)), "public")
  HEADER = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "header.html"))
  FOOTER = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "footer.html"))

  def initialize(remote_path)
    @remote_path = remote_path
    @dir = Dir.mktmpdir('readcode')
    @name = @remote_path.gsub(Reader::PROTOCOLRX,'')
    @filepath = @name.gsub('/', '.') + ".html"
    @toc = Tempfile.new(@filepath + ".code")
    @code = Tempfile.new(@filepath + ".code")
    @outpath = File.join(PUBLIC_DIR, @filepath)
  end

  def export
    clone
    render
    write
    outpath
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
      f.puts "<div class=toc>"
      @toc.rewind
      @toc.each_line do |l|
        f.write l
      end
      f.puts "</div>"
      #write code
      f.puts "<div class=code>"
      @code.rewind
      @code.each_line do |l|
        f.write l
      end
      f.puts "</div>"
      #write footer
      f.write FOOTER.gsub("REPONAME", @name)
    end

    @toc.unlink
    @code.unlink
  end

  def render
    puts "rendering"

    #write all trees recursively
    write_tree "", @master

    puts "rendering done"
  end

  def write_tree(root, tree)
    if root != ""
      @toc.puts "<li>"
      @toc.puts "<h4>#{root}</h4>"
    end
    @toc.puts "<ul>"
    #write all the blobs first
    tree.each_blob do |b|
      write_blob root, b
    end

    #recursively write all the trees
    tree.each_tree do |t|
      write_tree File.join(root, t[:name]), @repo.lookup(t[:oid])
    end
    @toc.puts "</ul>"
    @toc.puts "</li>" if root != ""
  end

  def write_blob(root, blob)
    obj =  @repo.lookup(blob[:oid])
    name = blob[:name]
    path = File.join(root, name)

    @toc.puts "<li><a href='##{path}'>#{name}#{" [binary]" if obj.binary?}</a></li>"
    return if obj.binary? #ignore binary objects

    lexer = lexer_for(path)
    @code.puts "<h3 id='#{path}'><a title='#{lexer || "Text"} file' href='##{path}'>#{path}</a></h3>"
    @code.puts highlight(obj.text, lexer)
  end

  def highlight(code, lexer)
    Pygments.highlight(code, lexer: lexer && Pygments.lexers.key?(lexer) ? lexer : "Text")
  end

  def lexer_for(path)
    p = File.join(@dir, path)
    lng = Linguist::FileBlob.new(p).language
    return lng.name if lng
  end

end
