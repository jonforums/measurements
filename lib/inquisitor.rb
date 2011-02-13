# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

require 'rci/initializer'

module Inquisitor

  def self.cmd=(cmd)
    @cmd = cmd
  end

  def self.tgt=(tgt)
    @tgt = tgt
  end

  def self.options=(opts)
    @options = opts
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
    puts "\n=== Known Workloads ===\n\n"
    Dir.glob(File.join(RCI::WORLD_CONFIG[:core_workloads], '*.rb')) do |f|
      puts " * #{File.basename(f)[/(\w*)/]}"
    end
  end
  private_class_method :ls

  def self.provider(cmd, wkld, *args)

    target = workload_target(cmd, wkld)
    active_tool = get_active_tool(cmd)

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

  def self.get_active_tool(group)
    RCI::USER_CONFIG["#{group}r".to_sym].select {|t| t[:active] }.first
  end
  private_class_method :get_active_tool

  def self.method_missing(method, *args)
    puts "[ERROR] I don\'t understand the '#{method}' command :("
    RCI.usage_and_exit
  end

end  # module Inquisitor
