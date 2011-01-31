:: Copyright (c) 2011, Jon Maken
:: License: 3-clause BSD (see project LICENSE file)
:: Revision: 01/29/2011 10:20:16 AM

@echo off
setlocal
:: echo initial:
:: echo   %%0 = %0
:: echo   %%* = %*
:: fix ruby.exe invocation when explicitly disabling RubyGems
if "x%1" == "x--disable-gems" (
  set NOGEM=%1
  for /F "tokens=1*" %%i in ("%*") do set RB_ARGS=%%j
) else (
  set NOGEM=
  set RB_ARGS=%*
)

:: echo pre call ruby:
:: echo   NOGEM = %NOGEM%
:: echo   RB_ARGS = %RB_ARGS%
ruby.exe %NOGEM% -x %~f0 %RB_ARGS%

endlocal
exit /b
#!ruby
RCI_CONFIG = 'config.yml'
RCI_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(RCI_ROOT, 'lib'))
$LOAD_PATH.unshift(File.join(RCI_ROOT))

require 'inquisitor'

Inquisitor.run
