in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input')

500.times do |i|
  begin
    f = 'bogus%s' % i
    require "#{File.join(in_dir, f)}"
  rescue LoadError
  end
end
