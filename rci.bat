:: Copyright (c) 2011, Jon Maken
:: License: 3-clause BSD (see project LICENSE file)
:: Revision: 02/13/2011 10:17:30 AM

@echo off
setlocal ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
:: echo initial:
:: echo   %%0 = %0
:: echo   %%* = %*

:: FIXME - broken if both flavors on PATH; n.p with Pik :)
jruby.exe --version > NUL 2>&1
if ERRORLEVEL 1 (
  set RUBY=ruby.exe
) else (
  set RUBY=jruby.exe
)

:: DANGER - this causes you to become a Luddite
for /F "usebackq tokens=1,2* delims= " %%i in (`%RUBY% --version`) do (
  set TMP=%%j
  set RB_MAJOR_VER=!TMP:~,3!
)

:: FIXME - fragile, extract to C .exe returning a canonical string
if "x%1" == "x--disable-gems" (
  set RB_OPTS=%1
  for /F "tokens=1*" %%i in ("%*") do (
    if "x%RB_MAJOR_VER%x" == "x1.8x" (
      set RB_OPTS=
      set SCRIPT_ARGS=%%j
    ) else (
      set SCRIPT_ARGS=%%j --disable-gems
    )
  )
) else (
  set RB_OPTS=
  set SCRIPT_ARGS=%*
)

:: echo pre call ruby:
:: echo   RUBY = %RUBY%
:: echo   RB_OPTS = %RB_OPTS%
:: echo   SCRIPT_ARGS = %SCRIPT_ARGS%
:: FIXME clear RB_OPTS for ruby.exe < 1.9
%RUBY% %RB_OPTS% -x %~f0 %SCRIPT_ARGS%

endlocal
exit /b
#!ruby
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'rci'

# load all plugins
Dir.glob('plugins/*.rb').sort.each do |p|
  begin
    require p
  rescue => ex
    warn '[WARN] problem loading \'%s\' plugin: %s' %
         [ File.basename(p)[/\w*/], ex.message ]
  end
end

Inquisitor.run
