c = (ENV['MEASURE_EXTENDED'] || 1).to_i

# set env var `N` to desired Hash size to test
n = (ENV['N'] || 6).to_i

k = 'aaa'
c.times do
  500_000.times do
    h = {}
    n.times { h[k] = true; h[k]; k = k.succ }
    h.each { |k,_| h[k] = h[k] }
  end
end
