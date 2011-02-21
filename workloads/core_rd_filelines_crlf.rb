fname = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'core_crlf.txt')
c = ENV['MEASURE_EXTENDED'] || 1

c.to_i.times do
  count = 0
  File.open(fname, 'r').each_line do |line|
    count += 1
  end
end
