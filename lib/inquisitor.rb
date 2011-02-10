# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

require 'rci/initializer'

module Inquisitor

  def self.usage
<<-EOT

usage: rci [RUBY_OPTS] COMMAND [CMD_OPTS]

where COMMAND is one of:

  bench <W|all>   benchmark workload W or all workloads
  exec W          execute workload W
  init            initialize environment
  ls              list all workloads
  trace W         trace workload W

where RUBY_OPTS are:

  --disable-gems  disable RubyGems use

where 'exec' CMD_OPTS are:

  --pause         pause before/after running workload
EOT
  end

  def self.usage_and_exit
    $stderr.puts usage
    exit(-1)
  end

  def self.run
    send(@cmd.to_sym, @tgt)
  end

  def self.init(*args)
    RCI::Initializer.init
  end
  private_class_method :init

  def self.ls(*args)
    puts "\n=== Known Workloads ==="
    Dir.glob(File.join(RCI::WORLD_CONFIG[:core_workloads], '*.rb')) do |f|
      puts " * #{File.basename(f)[/(\w*)/]}"
    end
  end
  private_class_method :ls

  def self.trace(*args)
    abort '[ERROR] must provide an API tracing workload' if args.first.nil?

    workload = '%s.rb' % args.first
    target = File.join(RCI::WORLD_CONFIG[:core_workloads], workload)
    abort "[ERROR] unknown trace workload '#{workload[/\w*/]}'" unless File.exists?(target)

    active_tracer = RCI::USER_CONFIG[:tracer].select {|t| t[:active] }.first

    begin
      tracer_name = active_tracer[:name]
      require "tracers/#{tracer_name.downcase}"
      tracer = eval("RCI::Tracers::#{tracer_name}.new('#{active_tracer[:exe]}')")

      puts "[INFO] tracing with '#{tracer_name}' API trace provider"
      tracer.call :target => target, :disable_gems => @options[:disable_gems]
    rescue => ex
      abort "[ERROR] problems loading/running '#{active_tracer[:name]}' API tracer"
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
                Dir.glob("#{File.join(RCI::WORLD_CONFIG[:core_workloads], '*.rb')}")
              else
                f = File.join(RCI::WORLD_CONFIG[:core_workloads], workload)
                unless File.exists?(f)
                  abort "[ERROR] unknown '#{workload[/\w*/]}' benchmark workload"
                end
                [ f ]
              end

    require 'benchmark'

    n = RCI::USER_CONFIG[:bench][:iterations]
    puts '%s' % RUBY_DESCRIPTION
    puts 'RubyGems disabled' if @options[:disable_gems]
    begin
      Benchmark.bmbm do |bm|
        targets.each do |target|
          bm.report "#{File.basename(target)[/\w*/]}" do
            n.times do
              load target
            end
          end
        end
      end
    rescue StandardError, LoadError => ex
      puts <<-EOT
\n
[ERROR] problem benchmarking workload, did you run 'rci init' first?
mesage: #{ex.message}
EOT
    end

  end
  private_class_method :bench

  def self.exec(*args)
    abort '[ERROR] must provide a workload to execute' if args.first.nil?

    workload = '%s.rb' % args.first
    target = File.join(RCI::WORLD_CONFIG[:core_workloads], workload)
    abort "[ERROR] unknown exec workload '#{workload[/\w*/]}'" unless File.exists?(target)

    if @options[:pause]
      print 'Press <ENTER> to start executing workload: '
      gets
    end

    print "\n[INFO] executing '#{workload[/\w*/]}' workload\n\n"
    begin
      load target
    rescue => ex
      abort "[ERROR] problem executing '#{workload[/\w*/]}' workload"
    end

    if @options[:pause]
      print 'Press <ENTER> to finish: '
      gets
    end
  end
  private_class_method :exec

  def self.method_missing(method, *args)
    puts "[ERROR] I don\'t understand the '#{method}' command :("
    Inquisitor.usage_and_exit
  end

  # parse args and options
  if ARGV.empty? || ARGV.delete('--help') || ARGV.delete('-h')
    Inquisitor.usage_and_exit
  end

  @options = {}
  if RUBY_VERSION < '1.9'
    ARGV.delete('--disable-gems')
  else
    @options[:disable_gems] = ARGV.delete('--disable-gems')
  end
  @options[:pause] = ARGV.delete('--pause')

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
