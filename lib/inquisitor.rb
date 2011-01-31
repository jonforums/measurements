# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module Inquisitor

  def self.usage
<<-EOT

usage: rci [RUBY_OPTS] COMMAND

where COMMAND is one of:

  bench <W|all>   benchmark workload W or all workloads
  exec W          execute workload W
  init            initialize environment
  ls              list all workloads
  trace W         trace workload W

where RUBY_OPTS are:

  --disable-gems  disable RubyGems use
EOT
  end

  def self.usage_and_exit
    $stderr.puts usage
    exit(-1)
  end

  def self.run
    send(@cmd.to_sym, @tgt)
  end

  # TODO implement
  def self.init(*args)
    puts '[TODO] implement user hookable environment initialization'
  end
  private_class_method :init

  def self.ls(*args)
    puts "\n=== Known Workloads ==="
    Dir.glob(File.join(RCI_ROOT, 'workloads', '*.rb')) do |f|
      puts ' * %s' % File.basename(f)[/(\w*)/]
    end
  end
  private_class_method :ls

  def self.trace(*args)
    abort '[ERROR] must provide an API tracing workload' if args.first.nil?
    workload = '%s.rb' % args.first
    target = File.join(RCI_ROOT, 'workloads', workload)
    abort '[ERROR] unknown trace workload \'%s\'' % workload[/\w*/] unless File.exists?(target)

    tracer = RCI::CONFIG[:tracer][:exe]
    #puts '[INFO] tracing with %s...' % File.basename(tracer)

    # TODO handle the UAC prompt by punting and requiring use of an elevated shell?
    #      implement UAC check and bail out with a message to use elevated shell
    #      generate timestamped log output files from the tracer
    #      encapsulate this in a config.yml selectable class
    system("start #{tracer} /quiet /minimized /backingfile #{File.join(RCI_ROOT, 'logs', 'api_trace.pml')}")
    system("#{tracer} /waitforidle")
    system("start ruby.exe \"#{target}\"")
    system("#{tracer} /terminate")
  end
  private_class_method :trace

  def self.bench(*args)
    abort '[ERROR] must provide a benchmarking workload' if args.first.nil?
    workload = case args.first
               when /\Aall\z/
                 'all'
               else
                 "#{args.first}.rb"
               end

    # TODO implement benchmarking all workloads
    #      implement benchmarking regex selectable workloads
    abort '[TODO] implement benchmarking all workloads...' if workload =~ /\Aall\z/i

    targets = [ File.join(RCI_ROOT, 'workloads', workload) ]
    unless targets.all? { |t| File.exists?(t) }
      abort '[ERROR] unknown benchmark workload(s)'
    end
    require 'benchmark'

    # TODO move n to config.yml
    n = 3
    Benchmark.bmbm do |bm|
      targets.each do |target|
        bm.report "#{File.basename(target)[/\w*/]}" do
          n.times do
            load target
          end
        end
      end
    end

  end
  private_class_method :bench

  # TODO implement
  def self.exec(*args)
    puts '[TODO] implement workload execution functionality'
  end
  private_class_method :exec

  def self.method_missing(method, *args)
    puts '[ERROR] I don\'t understand the \'%s\' command :(' % method
    Inquisitor.usage_and_exit
  end

  # parse args
  if ARGV.empty? || ARGV.delete('--help') || ARGV.delete('-h')
    Inquisitor.usage_and_exit
  end

  @cmd = ARGV.delete('bench') ||
         ARGV.delete('exec')  ||
         ARGV.delete('init')  ||
         ARGV.delete('ls')    ||
         ARGV.delete('trace')
  @cmd = ARGV[0] if @cmd.nil?

  # TODO review this way of sending in a subcommand or a workload
  @tgt = ARGV.shift unless ARGV.empty?

  Inquisitor.usage_and_exit unless ARGV.empty?

end  # module Inquisitor
