module Grabble
  class Site
    attr_accessor :url, :hostname, :hostnames, :exclude, :reject

    def initialize(hash)
      @url = hash['url'] || nil
      @hostname = @url.split('/')[2]
      @hostnames = clean(hash['hostnames'] || [])
      @exclude = clean(hash['exclude'] || Config.site_defaults['exclude'])
      @reject = clean(hash['reject'] || Config.site_defaults['reject'])
    end

    def clean(ary)
      ary.map do |item|
        item.strip
      end
    end
  end
end
