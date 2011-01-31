# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

module RCI
  CONFIG_FILE = 'config.yml'

  require 'yaml'
  YAML::ENGINE.yamler = 'psych' if defined?(YAML::ENGINE)

  begin
    CONFIG = YAML.load_file(File.join(RCI_ROOT, CONFIG_FILE))
  rescue
    abort '[ERROR] problem with \'%s\' configuration file' % CONFIG_FILE
  end

end
