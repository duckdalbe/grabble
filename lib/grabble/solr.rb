module Grabble
  class Solr
    def self.solr
      @solr ||= RSolr.connect(:url => Config.solr_baseurl)
    end

    def self.update(site, url, filepath)
      Grabble.log.debug "Preparing solr-update for #{url}"
      Grabble.log.debug "Finding Content-Type for #{filepath}"
      stdin, stdout, stderr = Open3.popen3('file', '-ib', filepath)
      content_type, charset = stdout.read.chomp.split(';').map { |str| str.strip }
      [stdin, stdout, stderr].each { |io| io.close }
      Grabble.log.debug "Content-Type: #{content_type}"

      case content_type
      when 'text/html', 'text/plain'
        content = File.read(filepath)
      when 'application/pdf'
        Grabble.log.debug "TODO: handling pdf-files"
        # TODO: save page.body to disk. run PDF::Toolkit.pdftotext on it, read result.
        # See http://pdf-toolkit.rubyforge.org/classes/PDF/Toolkit.html#M000003
        #content = ''
        return false
      else
        Grabble.log.debug "Skipping unhandled content-type '#{content_type}'"
        return false
      end

      Grabble.log.debug "Posting update to solr"
      resp = @solr.post('update/extract',
                        :data => content,
                        :params => {
                                     'fmap.content' => 'attr_content',
                                     'literal.id' => url,
                                     'attr_site' => site.hostname,
                                     'lastchanged' => File.mtime(filepath) 
                                   },
                        :headers => { 'Content-Type' => 'text/html'}
                       )
      Grabble.log.debug("response: #{resp.inspect}")
    end

    def self.delete(*ids)
      ids = ids.flatten.compact
      if ids.empty?
        Grabble.log.debug "Nothing to delete from solr-index"
        return nil
      else
        Grabble.log.debug "Sending delete to solr for ids: #{ids.inspect}"
        solr.delete_by_id(ids)
      end
    end

    def self.commit
      Grabble.log.debug "Sending commit to solr"
      solr.commit
    end

    def self.urls_in_index(hostname)
      Grabble.log.debug "Fetching URLs from index for hostname #{hostname.inspect}"
      resp = solr.get('select',
                      :params => {
                                   #:q => "site:#{hostname}/",
                                   :q => "id:*//#{hostname}/*",
                                   :fl => 'id',
                                   :rows => 9999
                                 }
                     )
      urls = resp['response']['docs'].map do |hash|
        hash['id']
      end
      Grabble.log.debug "Found URls: #{urls.inspect}"
      urls
    end
  end
end
