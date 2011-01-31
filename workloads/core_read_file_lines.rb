# FIXME refactor to something less fragile and intrusive
fname = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'lesmiserables.txt')

count = 0
File.open(fname, 'r').each_line do |line|
  count += 1
end
