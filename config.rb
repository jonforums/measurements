module RCI

  USER_CONFIG = {
    # general configuration
    :extended_iterations => 3,

    # additional user-defined (fully qualified) directories
    :dirs => {
      :my_workloads => 'c:/workloads',
      :ruby_source => 'c:/Users/Jon/Documents/RubyDev/ruby-git'
    },

    # API tracer configuration
    :tracer => [
      {
        :name => 'ProcessMonitor',
        :active => true,
        :exe => 'C:/winsystools/ProcessMonitor/procmon.exe'
      },
      {
        :name => 'APIMonitor',
        :active => false,
        :exe => ' c:/winsystools/APIMonitor/apimonitor-x86.exe'
      }
    ],

    # Profiler configuration
    :profiler => [
      {
        :name => 'AmplifierXE',
        :active => true,
        :exe => 'C:/Program Files/Intel/VTune Amplifier XE 2011/bin32/amplxe-cl.exe'
      },
      {
        :name => 'AQtime',
        :active => false,
        :exe => 'C:/Program Files/SmartBear/AQtime 7/Bin/AQtime.exe'
      }
    ],

    # Benchmarking configuration
    :bench => {
      :iterations => 3
    }
  }

end
