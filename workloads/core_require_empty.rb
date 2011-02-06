in_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'input', 'empty_files')

10.times do
  100.times do |i|
    begin
      f = 'empty%s' % i
      require "#{File.join(in_dir, f)}"
    rescue LoadError
      abort "\n[ERROR] unable to load test file, did you run 'rci init'?"
    end
  end
end
