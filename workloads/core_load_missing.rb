1_000.times do |i|
  begin
    load "input/bogus#{i}"
  rescue LoadError
  end
end
