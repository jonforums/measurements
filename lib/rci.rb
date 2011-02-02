# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)
# self.ruby implementation sourced from RubyGems

require 'rbconfig'

module RCI
  CONFIG_FILE = 'config.yml'
  WORLD_CONFIG = Hash.new do |cfg,k|
    cfg[k] = RbConfig::CONFIG[k.to_s]
  end

  require 'yaml'
  YAML::ENGINE.yamler = 'psych' if defined?(YAML::ENGINE)

  begin
    USER_CONFIG = YAML.load_file(File.join(RCI_ROOT, CONFIG_FILE))
  rescue
    abort '[ERROR] problem loading \'%s\' configuration file' % CONFIG_FILE
  end

  # basic config.yml checks
  if USER_CONFIG[:tracer].select {|t| t[:active] }.length != 1
    abort '[ERROR] \'%s\' must configure only one active tracer' % CONFIG_FILE
  end

  # convenience merge of select user config into world config
  WORLD_CONFIG[:workloads_dir] = File.join(RCI_ROOT, RCI::USER_CONFIG[:dirs][:workloads])
  WORLD_CONFIG[:logs_dir] = File.join(RCI_ROOT, RCI::USER_CONFIG[:dirs][:logs])

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
