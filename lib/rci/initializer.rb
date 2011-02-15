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

      generate_dirs
      generate_empty_files
      generate_text_files

      post_init
    end

    def self.generate_dirs
      puts '[INFO] generating required directories...'
      unless File.directory?(RCI::WORLD_CONFIG[:core_input])
        FileUtils.mkdir_p(RCI::WORLD_CONFIG[:core_input])
      end
      unless File.directory?(RCI::WORLD_CONFIG[:logs_dir])
        FileUtils.mkdir_p(RCI::WORLD_CONFIG[:logs_dir])
      end
    end
    private_class_method :generate_dirs

    def self.generate_empty_files
      puts '[INFO] generating empty test files...'
      empty_dir = File.join(RCI::WORLD_CONFIG[:core_input], 'empty_files')
      FileUtils.mkdir_p(empty_dir) unless File.directory?(empty_dir)
      100.times do |i|
        FileUtils.touch(File.join(empty_dir, "empty#{i}.rb"))
      end

      nested_dir = File.join(empty_dir, 'a', 'b', 'c', 'd', 'e')
      FileUtils.mkdir_p(nested_dir) unless File.directory?(nested_dir)
      100.times do |i|
        FileUtils.touch(File.join(nested_dir, "nested_empty#{i}.rb"))
      end
    end
    private_class_method :generate_empty_files

    def self.generate_text_files
      puts '[INFO] generating big text test files...'
      s = [
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        'Quisque gravida ipsum sit amet purus ultricies eu feugiat risus ullamcorper.',
        '',
        'Aliquam arcu turpis, bibendum quis consequat vestibulum, sagittis quis purus.',
        'Aliquam eget augue purus, et molestie risus. In sollicitudin interdum mattis.',
        'Vestibulum justo ligula, accumsan ac mattis a, pharetra nec arcu.'
      ]

      { 'core_lf.txt' => "\n", 'core_crlf.txt' => "\r\n" }.each_pair do |k,v|
        File.open(File.join(RCI::WORLD_CONFIG[:core_input], k), 'wb') do |f|
          500_000.times do
            f.write("#{s[rand(5)]}#{v}")
          end
        end
      end

    end
    private_class_method :generate_text_files

  end
end
