fname = File.expand_path('../input/core_crlf.txt', File.dirname(__FILE__))

c = ENV['MEASURE_EXTENDED'] || 1

c.to_i.times do
  count = 0
  File.open(fname, 'rb').each_line do |line|
    count += 1
  end
end
