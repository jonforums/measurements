# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module Inquisitor

  def self.usage
<<-EOT

usage: rci [RUBY_OPTS] COMMAND [SUBCOMMAND] [CMD_OPTS]

where COMMAND is one of:

  init   initialize RCI environment
  trace  trace a workload
  bench  benchmark workloads
  exec   execute a workload

where RUBY_OPTS are:

  --disable-gems  disable RubyGems use

where 'trace' SUBCOMMAND is one of:

  WORKLOAD  trace given WORKLOAD

where 'bench' SUBCOMMAND is one of:

  all       benchmark all workloads
  WORKLOAD  benchmark given WORKLOAD

where 'exec' SUBCOMMAND is one of:

  WORKLOAD  execute given WORKLOAD
EOT
  end

  def self.usage_and_exit
    $stderr.puts usage
    exit(-1)
  end

  def self.run(*args)
    #send(args.first)
    send(@cmd)
  end

  def self.init
    puts 'init-ing...'
  end
  private_class_method :init

  def self.trace
    puts 'tracing...'
  end
  private_class_method :trace

  def self.bench
    puts 'benchmarking...'
  end
  private_class_method :bench

  def self.exec
    puts 'executing...'
  end
  private_class_method :exec

  SUBCOMMANDS = %w[
    all
  ]

  # parse args
  if ARGV.empty? || ARGV.delete('--help') || ARGV.delete('-h')
    Inquisitor.usage_and_exit
  end

  @cmd = ARGV.delete('init')  ||
         ARGV.delete('trace') ||
         ARGV.delete('bench') ||
         ARGV.delete('exec')

  Inquisitor.usage_and_exit unless ARGV.empty?

end  # module Inquisitor
