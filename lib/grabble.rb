require 'yaml'
require 'uri'
require 'rsolr'
require 'logger'
require 'open3'

$:.unshift File.dirname(__FILE__)
require 'grabble/site'
require 'grabble/config'
require 'grabble/wget'
require 'grabble/solr'
require 'grabble/contentfile'
require 'grabble/log'

module Grabble
  module_function
  def log
    @log ||= Logger.new(Config['logfile'])
  end
end
