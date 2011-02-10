# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  module Profilers
    class AmplifierXE
      # download: http://software.intel.com/en-us/articles/intel-vtune-amplifier-xe/

      def initialize(exe)
        @exe = exe
      end

      # TODO fold in the following
      #      amplxe-cl.exe --collect hotspots -knob accurate-cpu-time-detection=true
      #        -follow-child -target-duration-type=short -no-allow-multiple-runs
      #        -no-analyze-system -data-limit=100 -slow-frames-threshold=40
      #        -fast-frames-threshold=100 --target-process ruby.exe
      def call(env)
        #log_file = 'api_trace_%s.pml' % Time.now.strftime('%Y-%m-%dT%k_%M_%S')
        puts @exe
        #system("start \"#{@exe}\" /quiet /minimized /backingfile #{File.join(RCI::WORLD_CONFIG[:logs_dir], log_file)}")
        #system("#{RCI.ruby} #{env[:disable_gems]} \"#{env[:target]}\"")
      end

    end
  end
end
