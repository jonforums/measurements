# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  module Tracers
    class ProcessMonitor

      def initialize(exe)
        @exe = exe
      end

      def call(env)
        # TODO implement UAC check and bail out with a message to use elevated shell
        #      generate timestamped log output files from the tracer
        #      how to cleverly avoid tracing Ruby startup?
        # FIXME figure out why JRuby doesn't like this

        #puts "Ruby: %s\ndisable_gems: %s\ntracer: %s\ntarget:%s" %
        #      [ RCI.ruby, @exe, env[:disable_gems], env[:target] ]

        system("start #{@exe} /quiet /minimized /backingfile #{File.join(RCI::WORLD_CONFIG[:logs_dir], 'api_trace.pml')}")
        system("#{@exe} /waitforidle")
        system("#{RCI.ruby} #{env[:disable_gems]} \"#{env[:target]}\"")
        system("#{@exe} /terminate")
      end

    end
  end
end
