# file: <RUBYINSTALLER_ROOT>/override/vtune_build.rb
if ENV['VTUNE_BUILD'] then
  puts '[INFO] Overriding to enable VTune profiled Ruby 1.9.x...'

  RubyInstaller::Ruby19.configure_options << "--with-vtune=c:/devlibs/vtune"
end
