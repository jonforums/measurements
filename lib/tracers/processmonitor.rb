# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  module Tracers
    class ProcessMonitor

      def initialize
        # FIXME ensure :name matches and is :active
        @tracer = RCI::CONFIG[:tracer][:exe]
      end

      def call(env)
        # TODO implement UAC check and bail out with a message to use elevated shell
        #      generate timestamped log output files from the tracer

        # FIXME figure out why JRuby doesn't like this

        #puts 'Ruby: %s, tracer: %s' % [ RCI.ruby, @tracer ]

        system("start #{@tracer} /quiet /minimized /backingfile #{File.join(RCI_ROOT, RCI::CONFIG[:dirs][:logs], 'api_trace.pml')}")
        system("#{@tracer} /waitforidle")
        system("#{RCI.ruby} \"#{env[:target]}\"")
        system("#{@tracer} /terminate")
      end

    end
  end
end
