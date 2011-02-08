fname = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'core_crlf.txt')

count = 0
File.open(fname, 'rb').each_line do |line|
  count += 1
end
