:: Copyright (c) 2011, Jon Maken
:: License: 3-clause BSD (see project LICENSE file)
:: Revision: 02/01/2011 9:52:50 AM

@echo off
setlocal
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

:: FIXME - fragile, extract to C .exe returning a canonical string
if "x%1" == "x--disable-gems" (
  set RB_OPTS=%1
  for /F "tokens=1*" %%i in ("%*") do (
    set SCRIPT_ARGS=%%j --disable-gems
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
RCI_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(RCI_ROOT, 'lib'))
$LOAD_PATH.unshift(File.join(RCI_ROOT))

require 'rci'
require 'inquisitor'

Inquisitor.run
