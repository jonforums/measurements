# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)
# self.ruby implementation sourced from RubyGems

require 'rbconfig'

module RCI
  RUBY_CONFIG = RbConfig::CONFIG
  CONFIG_FILE = 'config.yml'

  require 'yaml'
  YAML::ENGINE.yamler = 'psych' if defined?(YAML::ENGINE)

  begin
    CONFIG = YAML.load_file(File.join(RCI_ROOT, CONFIG_FILE))
  rescue
    abort '[ERROR] problem with \'%s\' configuration file' % CONFIG_FILE
  end

  def self.ruby
    if @ruby.nil? then
      @ruby = File.join(RUBY_CONFIG['bindir'],
                        RUBY_CONFIG['ruby_install_name'])
      @ruby << RUBY_CONFIG['EXEEXT']

      # escape string in case path to ruby executable contain spaces.
      @ruby.sub!(/.*\s.*/m, '"\&"')
    end

    @ruby
  end

end
