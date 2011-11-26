module Grabble
  class Config
    def self.load(path)
      @config = YAML.load(File.open(path))
      @config['sites'].map! do |hash|
          Site.new(hash)
      end
      true
    end

    def self.method_missing(sym, *args, &block)
      @config[sym.to_s] || super
    end

    def self.[](arg)
      @config[arg]
    end
  end
end
