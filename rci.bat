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

:: FIXME - fragile (positional) way to send an option to ruby
if "x%1" == "x--disable-gems" (
  set NOGEM=%1
  for /F "tokens=1*" %%i in ("%*") do (
    set RB_ARGS=%%j
  )
) else (
  set NOGEM=
  set RB_ARGS=%*
)

:: echo pre call ruby:
:: echo   RUBY = %RUBY%
:: echo   NOGEM = %NOGEM%
:: echo   RB_ARGS = %RB_ARGS%
%RUBY% %NOGEM% -x %~f0 %RB_ARGS%

endlocal
exit /b
#!ruby
RCI_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(RCI_ROOT, 'lib'))
$LOAD_PATH.unshift(File.join(RCI_ROOT))

require 'rci'
require 'inquisitor'

Inquisitor.run
