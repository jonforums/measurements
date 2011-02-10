# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  module Tracers
    class APIMonitor
      # download: http://www.rohitab.com/apimonitor

      def initialize(exe)
        @exe = exe
      end

      def call(env)
        raise NotImplementedError, "[TODO] implement #{self.class.name}#call(env)"
      end
    end
  end
end
