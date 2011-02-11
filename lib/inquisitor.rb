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
  profile W       profile workload W

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
    unless @cmd =~ /ls|init/ || @tgt
      abort "[ERROR] must provide a workload to '#{@cmd}'"
    end

    case @cmd
    when 'trace', 'profile'
      provider(@cmd, @tgt)
    else
      send(@cmd.to_sym, @tgt)
    end
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

  def self.provider(cmd, wkld, *args)

    target = workload_target(cmd, wkld)
    active_tool = RCI::USER_CONFIG["#{cmd}r".to_sym].select {|t| t[:active] }.first

    begin
      tool_name = active_tool[:name]
      require "#{cmd}rs/#{tool_name.downcase}"
      tool = eval("RCI::#{cmd.capitalize}rs::#{tool_name}.new('#{active_tool[:exe]}')")

      puts "[INFO] running '#{tool_name}' #{cmd} provider"
      tool.call :target => target, :disable_gems => @options[:disable_gems]
    rescue => ex
      abort "[ERROR] problem loading/running '#{tool_name}' provider"
    end

  end
  private_class_method :provider

  def self.bench(*args)

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

    cache = $LOADED_FEATURES.dup
    n = RCI::USER_CONFIG[:bench][:iterations]

    puts '%s' % RUBY_DESCRIPTION
    puts 'RubyGems disabled' if @options[:disable_gems]
    begin
      Benchmark.bmbm do |bm|
        targets.each do |target|
          bm.report "#{File.basename(target)[/\w*/]}" do
            n.times do
              $LOADED_FEATURES.clear
              $LOADED_FEATURES.concat(cache)
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

    wkld = args.first
    target = workload_target('exec', wkld)

    if @options[:pause]
      print 'Press <ENTER> to start executing workload: '
      gets
    end

    print "\n[INFO] executing '#{wkld[/\w*/]}' workload\n\n"
    begin
      load target
    rescue => ex
      abort "[ERROR] problem executing '#{wkld[/\w*/]}' workload"
    end

    if @options[:pause]
      print 'Press <ENTER> to finish: '
      gets
    end
  end
  private_class_method :exec

  def self.workload_target(cmd, wkld)
    workload = '%s.rb' % wkld
    target = File.join(RCI::WORLD_CONFIG[:core_workloads], workload)
    abort "[ERROR] unknown #{cmd} workload '#{workload[/\w*/]}'" unless File.exists?(target)
    target
  end
  private_class_method :workload_target

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

  # FIXME overwrites due to sequencing issue
  @cmd = ARGV.delete('bench') ||
         ARGV.delete('exec')  ||
         ARGV.delete('init')  ||
         ARGV.delete('ls')    ||
         ARGV.delete('trace') ||
         ARGV.delete('profile')
  @cmd = ARGV[0] if @cmd.nil?

  # TODO review this way of sending in a subcommand or a workload
  @tgt = ARGV.shift unless ARGV.empty?

  Inquisitor.usage_and_exit unless ARGV.empty?

end  # module Inquisitor
