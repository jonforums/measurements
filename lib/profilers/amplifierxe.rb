# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  module Profilers
    class AmplifierXE
      # download: http://software.intel.com/en-us/articles/intel-vtune-amplifier-xe/

      def initialize(exe)
        @exe = exe
      end

      def call(env)
        cmd = "\"#{@exe}\""
        cmd << ' -collect hotspots -knob accurate-cpu-time-detection=true -follow-child'
        cmd << ' -target-duration-type=short -no-allow-multiple-runs -no-analyze-system'
        cmd << ' -data-limit=100 -slow-frames-threshold=40 -fast-frames-threshold=100'
        cmd << " -user-data-dir=\"#{RCI::WORLD_CONFIG[:logs_dir]}\""
        cmd << " -result-dir=\"hotspots_#{Time.now.strftime('%Y-%m-%dT%H_%M_%S')}\""
        cmd << " -quiet \"#{RCI.ruby}\" #{env[:disable_gems]} \"#{env[:target]}\""

        #puts cmd
        system(cmd)
      end

    end
  end
end
