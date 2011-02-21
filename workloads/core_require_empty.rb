in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'empty_files')

c = ENV['MEASURE_EXTENDED'] || 1

c.to_i.times do
  10.times do
    100.times do |i|
      f = 'empty%s' % i
      require "#{File.join(in_dir, f)}"
    end
    $LOADED_FEATURES.clear
  end
end
