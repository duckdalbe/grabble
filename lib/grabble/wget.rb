class Grabble::Wget
  def self.crawl(site)
    # TODO:
    # - fetch urls for site from solr and spider for 404, delete those from solr
    # - let wget crawl and parse output for downloaded files, add those to solr
    if ! site.kind_of?(Grabble::Site)
      Grabble.log.error "Error: need a Site as input: #{site.inspect}"
      return false
    elsif ! site.url
      debug "Skipping site, missing url: #{site.inspect}"
      return false
    end
     
    Grabble.log.debug "Crawling for site #{site.inspect}"

    excludelist = site.exclude.join(',')
    rejectlist = site.reject.join(',')
    hostnamelist = site.hostnames.join(',')
    Grabble.log.debug "excludelist: #{excludelist.inspect}"
    Grabble.log.debug "rejectlist: #{rejectlist.inspect}"
    Grabble.log.debug "hostnamelist: #{hostnamelist.inspect}"

    hostnamelist = "-H -D #{hostnamelist}" unless hostnamelist.to_s.empty?
    rejectlist = "-R#{rejectlist}" unless rejectlist.to_s.empty?
    excludelist = "-X#{excludelist}" unless excludelist.to_s.empty?

    Grabble.log.info "Starting crawl on #{site.url.inspect}"
    vars = Open3.popen3('wget', '--no-check-certificate',
                        '--protocol-directories', '-nv', '-m',
                        excludelist, rejectlist, hostnamelist, site.url)
    stdin, stdout, stderr, wait_thr = *vars

    # parse wgetlog for fetched URLs
    fetchedurls = {}
    stderr.read.each_line do |line|
      if line.match(/.* URL:([^ ]*).* -> "([^ "]*)".*/)
        fetchedurls[$1] = $2
      end
    end
    Grabble.log.debug "Fetched urls: #{fetchedurls.inspect}"
    fetchedurls
  end

  def self.spider(*urls)
    urls = urls.flatten.compact
    if urls.empty?
      Grabble.log.debug "Spidering skipped, empty input"
      return []
    else
      Grabble.log.debug "Spidering for #{urls.size} urls"
      vars = Open3.popen3('wget', '--spider', '-nv', urls)
      stdin, stdout, stderr, wait_thr = *vars
      stdin.close
      brokenurls = []
      stderr.read.each_line do |line|
        Grabble.log.debug "wget: #{line.chomp}"
        if line.match(/^http/)
          brokenurls << line.chomp(":\n")
        end
      end
      [stdout, stderr].each { |io| io.close }
      Grabble.log.debug "Found broken urls: #{brokenurls.inspect}"
      brokenurls
    end
  end

  def self.encode(str)
    URI.escape(str.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))            
  end
end
