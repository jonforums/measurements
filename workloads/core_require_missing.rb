1_000.times do |i|
  begin
    require "input/bogus#{i}"
  rescue LoadError
  end
end
