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
      generate_text_files

      post_init
    end

    def self.generate_empty_files
      puts '[INFO] generating empty test files...'
      empty_dir = File.join(RCI::WORLD_CONFIG[:core_input], 'empty_files')
      FileUtils.mkdir(empty_dir) unless File.directory?(empty_dir)
      100.times do |i|
        FileUtils.touch(File.join(empty_dir, "empty#{i}.rb"))
      end
    end
    private_class_method :generate_empty_files

    def self.generate_text_files
      puts '[INFO] generating big text test files...'
      s = [
        'Ipsum lorem ipsum dipsum dippity do cicero quotes from some lame book that one does',
      ]

      { 'core_lf.txt' => '\n', 'core_crlf.txt' => '\r\n' }.each_pair do |k,v|
        File.open(File.join(RCI::WORLD_CONFIG[:core_input], k), 'wb') do |f|
          200_000.times do
            f.write("#{s[0]}#{v}")
          end
        end
      end

    end
    private_class_method :generate_text_files

  end
end
