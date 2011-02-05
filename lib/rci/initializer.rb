module RCI
  module Initializer

    def self.pre_init
    end

    def self.post_init
    end

    def self.init(*args)
      pre_init
      # do something
      post_init
    end

  end
end
