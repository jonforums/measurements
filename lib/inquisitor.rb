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
    Dir.glob(File.join(RCI::WORLD_CONFIG[:workloads_dir], '*.rb')) do |f|
      puts ' * %s' % File.basename(f)[/(\w*)/]
    end
  end
  private_class_method :ls

  def self.trace(*args)
    abort '[ERROR] must provide an API tracing workload' if args.first.nil?
    workload = '%s.rb' % args.first
    target = File.join(RCI::WORLD_CONFIG[:workloads_dir], workload)
    abort '[ERROR] unknown trace workload \'%s\'' % workload[/\w*/] unless File.exists?(target)

    active_tracer = RCI::USER_CONFIG[:tracer].select {|t| t[:active] }.first

    begin
      tracer_name = active_tracer[:name]
      require "tracers/#{tracer_name.downcase}"
      tracer = eval("RCI::Tracers::#{tracer_name}.new('#{active_tracer[:exe]}')")

      puts '[INFO] tracing with \'%s\' API trace provider' % tracer_name
      tracer.call :target => target, :disable_gems => @options[:disable_gems]
    rescue
      abort '[ERROR] problems loading or running \'%s\' API tracer' % active_tracer[:name]
    end

  end
  private_class_method :trace

  def self.bench(*args)
    abort '[ERROR] must provide a benchmarking workload' if args.first.nil?
    workload = case args.first
               when /\Aall\z/i
                 'all'
               else
                 "#{args.first}.rb"
               end

    # TODO implement benchmarking regex selectable workloads
    targets = case workload
              when /\Aall\z/
                Dir.glob("#{File.join(RCI::WORLD_CONFIG[:workloads_dir], '*.rb')}")
              else
                f = File.join(RCI::WORLD_CONFIG[:workloads_dir], workload)
                unless File.exists?(f)
                  abort '[ERROR] unknown \'%s\' benchmark workload' % workload[/\w*/]
                end
                [ f ]
              end

    require 'benchmark'

    n = RCI::USER_CONFIG[:bench][:iterations]
    puts '%s' % RUBY_DESCRIPTION
    puts 'RubyGems disabled' if @options[:disable_gems]
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

  @options = {}
  @options[:disable_gems] = ARGV.delete('--disable-gems')

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
