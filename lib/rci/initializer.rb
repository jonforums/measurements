# Copyright (c) 2011, Jon Maken
# License: 3-clause BSD (see project LICENSE file)

require 'fileutils'

module RCI
  module Initializer

    # TODO what arg(s) to pass each hook?
    #      core then pre_init hooks order correct?
    def self.pre_init
      # do core stuff

      # do all registered pre_init_hooks
    end

    # TODO what arg(s) to pass each hook?
    def self.post_init
      # do core stuff

      # do all registered post_init_hooks
    end

    def self.init(*args)
      pre_init

      generate_empty_files

      post_init
    end

    def self.generate_empty_files
      puts '[INFO] generating empty test files...'
      empty_dir = File.join(RCI_ROOT, 'input', 'empty_files')
      FileUtils.mkdir(empty_dir) unless File.directory?(empty_dir)
      100.times do |i|
        FileUtils.touch("input/empty_files/empty#{i}.rb")
      end
    end
    private_class_method :generate_empty_files

  end
end
