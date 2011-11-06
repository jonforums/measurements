# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)
#   - self.ruby impl from RubyGems

require 'inquisitor'
require 'rbconfig'

module RCI

  VERSION = '0.4.0'

  def self.version
    "rci v#{RCI::VERSION} - Ruby Code Inspector"
  end

  def self.usage
<<-EOT

#{version}
usage: rci [RUBY_OPTS] COMMAND [CMD_OPTS]

where COMMAND is one of:
  bench <W|all>   benchmark workload W or all workloads
  exec W          execute workload W
  init            initialize environment
  ls              list all workloads
  profile W       profile workload W
  trace W         trace workload W

generic options:
  -h, --help      show this help message
  -v, --version   show RCI version

where RUBY_OPTS are:
  --disable-gems  disable RubyGems use

where common CMD_OPTS are:
  --extended      use extended duration workload

where 'exec' CMD_OPTS are:
  --pause         pause before/after running workload
EOT
  end

  def self.usage_and_exit(code=-1)
    $stderr.puts RCI.usage
    exit(code)
  end

  # parse args and options; go trollop if becomes too ugly
  if ARGV.empty? || ARGV.delete('--help') || ARGV.delete('-h')
    RCI.usage_and_exit(0)
  end

  if ARGV.delete('--version') || ARGV.delete('-v')
    $stderr.puts version
    exit(0)
  end

  options = {}
  if RUBY_VERSION < '1.9'
    ARGV.delete('--disable-gems')
  else
    options[:disable_gems] = ARGV.delete('--disable-gems')
  end
  options[:pause] = ARGV.delete('--pause')
  options[:extended] = ARGV.delete('--extended')

  # FIXME overwrites due to sequencing issue
  cmd = ARGV.delete('bench')   ||
        ARGV.delete('exec')    ||
        ARGV.delete('init')    ||
        ARGV.delete('ls')      ||
        ARGV.delete('profile') ||
        ARGV.delete('trace')
  cmd = ARGV[0] if cmd.nil?

  # TODO review this way of sending in a subcommand or a workload
  tgt = ARGV.shift unless ARGV.empty?

  RCI.usage_and_exit unless ARGV.empty?

  Inquisitor.cmd = cmd
  Inquisitor.tgt = tgt
  Inquisitor.options = options

  # configuration setup
  ROOT = File.dirname(File.expand_path('..', __FILE__))
  CONFIG_FILE = 'config.yml'
  WORLD_CONFIG = Hash.new do |cfg,k|
    cfg[k] = RbConfig::CONFIG[k.to_s]
  end

  WORLD_CONFIG[:core_workloads] = File.join(RCI::ROOT, 'workloads')
  WORLD_CONFIG[:core_input] = File.join(RCI::ROOT, 'input')

  # prefer Psych YAML engine
  begin
    require 'psych'
  rescue LoadError
  end
  require 'yaml'

  begin
    USER_CONFIG = YAML.load_file(File.join(RCI::ROOT, CONFIG_FILE))
  rescue
    abort "[ERROR] problem loading '#{CONFIG_FILE}' configuration file"
  end

  # basic config.yml checks
  if USER_CONFIG[:tracer].select {|t| t[:active] }.length != 1
    abort "[ERROR] '#{CONFIG_FILE}' must configure only one active tracer"
  end

  if USER_CONFIG[:extended_iterations] && options[:extended]
    ENV['MEASURE_EXTENDED'] = USER_CONFIG[:extended_iterations].to_s
  end

  # convenience merge of select user config into world config
  WORLD_CONFIG[:logs_dir] = unless RCI::USER_CONFIG[:dirs][:logs]
                              File.join(RCI::ROOT, 'logs')
                            else
                              RCI::USER_CONFIG[:dirs][:logs]
                            end

  # hook infrastructure
  @pre_init_hooks  ||= []
  @post_init_hooks ||= []

  def self.pre_init_hooks
    @pre_init_hooks
  end

  def self.post_init_hooks
    @post_init_hooks
  end

  # TODO document hook Proc args
  def self.pre_init(&hook)
    @pre_init_hooks << hook
  end

  # TODO document hook Proc args
  def self.post_init(&hook)
    @post_init_hooks << hook
  end

  def self.ruby
    if @ruby.nil? then
      @ruby = File.join(WORLD_CONFIG[:bindir],
                        WORLD_CONFIG[:ruby_install_name])
      @ruby << WORLD_CONFIG[:EXEEXT]

      # escape string in case path to ruby executable contain spaces.
      @ruby.sub!(/.*\s.*/m, '"\&"')
    end

    @ruby
  end

  def self.windows?
    WORLD_CONFIG[:host_os] =~ /mswin|mingw/
  end

end
