in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input',
                   'empty_files', 'a', 'b', 'c', 'd', 'e')
c = ENV['MEASURE_EXTENDED'] || 1

cache = $LOADED_FEATURES.dup
c.to_i.times do
  10.times do
    100.times do |i|
      f = 'nested_empty%s' % i
      require "#{File.join(in_dir, f)}"
    end
    $LOADED_FEATURES.clear
    $LOADED_FEATURES.concat(cache)
  end
end
