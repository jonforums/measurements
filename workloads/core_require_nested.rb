in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input',
                   'empty_files', 'a', 'b', 'c', 'd', 'e')

100.times do |i|
  f = 'nested_empty%s' % i
  require "#{File.join(in_dir, f)}"
end
