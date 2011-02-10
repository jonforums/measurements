in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'empty_files')

10.times do
  100.times do |i|
    f = 'empty%s' % i
    require "#{File.join(in_dir, f)}"
  end
end
