# encoding: utf-8

Gem::Specification.new do |s|
  s.name         = "grabble"
  s.version      = '0.1'
  s.authors      = ["duckdalbe"]
  s.email        = "grabble@duckdalbe.org"
  s.homepage     = "http://github.com/duckd/grabble"
  s.summary      = "Grabble is glueing wget to solr."
  s.description  = "A light-weight and yet not entirely stupid crawler to keep a solr index up to date.."
  s.files        = `git ls-files lib ext bin`.split("\n") + %w(README)
  s.executables =  [ 'grabble' ]
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.add_dependency('rsolr','>=1.0.2')
end
