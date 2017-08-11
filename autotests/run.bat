@echo off
call :MAIN %* || exit /b 1
goto :EOF

:MAIN
setlocal
  call ..\c-plus-plus.conf.bat
  set RUNTIME=../src/srlib/refalrts.cpp ^
    ../src/srlib/platform-Windows/refalrts-platform-specific.cpp
  if {%1}=={} (
    for %%s in (*.sref *.ref) do call :RUN_TEST %%s || exit /b 1
    call :RUN_ALL_TESTS_DIR || exit /b 1
  ) else (
    if {%1}=={--dir} (
      call :RUN_ALL_TESTS_DIR || exit /b 1
    ) else (
      for %%s in (%*) do call :RUN_TEST %%s || exit /b 1
    )
  )
  if exist _test_prefix.exe-prefix erase _test_prefix.exe-prefix
endlocal
goto :EOF

:PREPARE_PREFIX
  if not exist _test_prefix.exe-prefix (
     echo Prepare common prefix...
    ..\bin\srefc-core -o _test_prefix.exe-prefix ^
      %COMMON_SRFLAGS% %SRFLAGS_NAT% 2>__error.txt
    if not exist _test_prefix.exe-prefix (
      echo CAN'T CREATE COMMON PREFIX, SEE __error.txt
      exit /b 1
    )
    erase __error.txt
    if exist *.obj erase *.obj
    if exist *.tds erase *.tds
    echo.
  )
  exit /b 0
goto :EOF

:RUN_ALL_TESTS_DIR
setlocal
  for /d %%d in (*) do (
    if exist %%d\run.bat (
      call :RUN_TEST_DIR %%d || exit /b 1
    )
  )
endlocal
goto :EOF

:RUN_TEST_DIR
setlocal
  echo Passing special test in dir %1...
  pushd %1
  call run.bat
  if errorlevel 1 (
    echo TEST FAILED
    popd
    exit /b 1
  )
  popd
endlocal
goto :EOF

:RUN_TEST
setlocal
  set COMMON_SRFLAGS= ^
    -c "%CPPLINEE%" ^
    --exesuffix=.exe ^
    --prelude=test-prelude.srefi ^
    -D../src/srlib ^
    -D../src/srlib/platform-Windows ^
    -f-DSTEP_LIMIT=1500 ^
    -f-DMEMORY_LIMIT=1000 ^
    -f-DIDENTS_LIMIT=200 ^
    -f-DDUMP_FILE="\\"__dump.txt\\"" ^
    -f-DDONT_PRINT_STATISTICS
  set SRFLAGS_PREF=--prefix=_test_prefix
  set SRFLAGS_NAT=refalrts refalrts-platform-specific
  for %%s in (%~n1) do call :RUN_TEST_AUX%%~xs %1 || exit /b 1
endlocal
goto :EOF

:RUN_TEST_ALL_MODES
setlocal
  find "%%" %1 > NUL
  if errorlevel 1 (
    call :PREPARE_PREFIX || exit /b 1
    set SRFLAGS_PLUS=%SRFLAGS_PREF%
  ) else (
    set SRFLAGS_PLUS=%SRFLAGS_NAT%
  )
  set SRFLAGS=
  call :%2 %1 || exit /b 1
  set SRFLAGS=--markup-context
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OP
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OR
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OPR
  call :%2 %1 || exit /b 1
  set SRFLAGS_PLUS=%SRFLAGS_NAT%
  set SRFLAGS=-Od
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OdP
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OdR
  call :%2 %1 || exit /b 1
  set SRFLAGS=-OdPR
  call :%2 %1 || exit /b 1
  set SRFLAGS=-F-DENABLE_DEBUGGER
  call :%2 %1 || exit /b 1
endlocal
goto :EOF

:RUN_TEST_AUX
setlocal
  call :RUN_TEST_ALL_MODES %1 RUN_TEST_AUX_WITH_FLAGS || exit /b 1
endlocal
goto :EOF

:RUN_TEST_AUX_WITH_FLAGS
setlocal
  echo Passing %1 (flags %SRFLAGS%)...
  set SREF=%1
  set RASL=%~n1.rasl
  set NATCPP=%~n1.cpp
  set EXE=%~n1.exe

  ..\bin\srefc-core %SREF% -o %EXE% %COMMON_SRFLAGS% %SRFLAGS% %SRFLAGS_PLUS% ^
    2> __error.txt
  if errorlevel 100 (
    echo COMPILER ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if not exist %EXE% (
    echo COMPILATION FAILED
    exit /b 1
  )

  if not exist %NATCPP% set NATCPP=

  %EXE%
  if errorlevel 1 (
    echo TEST FAILED, SEE __dump.txt
    exit /b 1
  )

  erase %RASL% %NATCPP% %EXE%
  if exist *.obj erase *.obj
  if exist *.tds erase *.tds
  if exist __dump.txt erase __dump.txt
  echo.
endlocal
goto :EOF

:RUN_TEST_AUX.FAILURE
setlocal
  call :RUN_TEST_ALL_MODES %1 RUN_TEST_AUX_WITH_FLAGS.FAILURE || exit /b 1
endlocal
goto :EOF

:RUN_TEST_AUX_WITH_FLAGS.FAILURE
setlocal
  echo Passing %1 (expecting failure, flags %SRFLAGS%)...
  set SREF=%1
  set RASL=%~n1.rasl
  set NATCPP=%~n1.cpp
  set EXE=%~n1.exe

  ..\bin\srefc-core %SREF% -o %EXE% %COMMON_SRFLAGS% %SRFLAGS% %SRFLAGS_PLUS% ^
    2> __error.txt
  if errorlevel 100 (
    echo COMPILER ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if not exist %EXE% (
    echo COMPILATION FAILED
    exit /b 1
  )

  if not exist %NATCPP% set NATCPP=

  %EXE%
  if not errorlevel 100 (
    echo TEST NOT EXPECTATIVE FAILED, SEE __dump.txt
    exit /b 1
  )

  erase %RASL% %NATCPP% %EXE%
  if exist *.obj erase *.obj
  if exist *.tds erase *.tds
  if exist __dump.txt erase __dump.txt
  echo Ok! This failure was normal and expected
  echo.
endlocal
goto :EOF

:RUN_TEST_AUX.BAD-SYNTAX
setlocal
  echo Passing %1 (syntax error recovering)...
  set SREF=%1
  set RASL=%~n1.rasl

  ..\bin\srefc-core --prelude=test-prelude.srefi -C %SRFLAGS% %1 2> __error.txt
  if errorlevel 100 (
    echo COMPILER ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if exist %RASL% (
    echo COMPILATION SUCCESSED, BUT EXPECTED SYNTAX ERROR
    erase %RASL%
    exit /b 1
  )
  echo Ok! Compiler didn't crash on invalid syntax
  echo.
endlocal
goto :EOF

:RUN_TEST_AUX.LEXGEN
setlocal
  call :PREPARE_PREFIX || exit /b 1

  echo Passing %1 (lexgen)...
  set SREF=%1

  ..\bin\lexgen --from=%SREF% --to=_lexgen-out.sref 2> __error.txt
  if errorlevel 100 (
    echo LEXGEN ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if not exist _lexgen-out.sref (
    echo LEXGEN FAILED
    exit /b 1
  )

  ..\bin\srefc-core _lexgen-out.sref -o _lexgen-out.exe %COMMON_SRFLAGS% ^
    %SRFLAGS_PREF% 2> __error.txt
  if errorlevel 100 (
    echo COMPILER ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if not exist _lexgen-out.rasl (
    echo COMPILATION FAILED
    exit /b 1
  )

  _lexgen-out.exe
  if errorlevel 1 (
    echo TEST FAILED, SEE __dump.txt
    exit /b 1
  )

  erase _lexgen-out.*
  if exist *.obj erase *.obj
  if exist *.tds erase *.tds
  if exist __dump.txt erase __dump.txt
  echo.
endlocal
goto :EOF

:RUN_TEST_AUX.BAD-SYNTAX-LEXGEN
setlocal
  echo Passing %1 (lexgen, syntax error recovering)...
  set SREF=%1

  ..\bin\lexgen --from=%SREF% --to=_lexgen-out.sref 2> __error.txt
  if errorlevel 100 (
    echo LEXGEN ON %1 FAILS, SEE __error.txt
    exit /b 1
  )
  erase __error.txt
  if exist _lexgen-out.sref (
    echo LEXGEN SUCCESSED, BUT EXPECTED SYNTAX ERROR
    exit /b 1
  )

  echo Ok! LexGen didn't crash on invalid syntax
  echo.
endlocal
goto :EOF
