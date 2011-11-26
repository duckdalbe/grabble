class Grabble::Contentfile
  attr_accessor :path, :url, :hostname

  def initialize(path)
    @path = path
    # 'index.html' is wget's default filename if none is provided, e.g. a
    # directory listing -- on the server the file might have a different name
    # so we need to strip that.
    @url = @path.sub('/', '://').chomp('index.html')
    @hostname = @path.split('/')[1]
  end

  def content
    File.read(@path)
  end
end
