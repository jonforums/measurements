c = (ENV['MEASURE_EXTENDED'] || 1).to_i

# set env var `N` to desired Hash size to test
n = (ENV['N'] || 6).to_i

c.times do
  500_000.times do
    h = {}
    n.times { |i| h[i] = true; h[i] }
    h.each { |k,_| h[k] = h[k] }
  end
end
