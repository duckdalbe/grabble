module Grabble
  class Logger < Logger
    def initialize(*args)
      super
      @level = ::DEBUG && Logger::DEBUG || Logger::INFO
      @progname = 'Grabble'
    end
  end
end
