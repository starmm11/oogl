@setlocal
@cd "%~dp0"
@set PATH=%PATH%;@CMAKE_FIXED_RUNTIME_OUTPUT_DIRECTORY@\Debug;@CMAKE_FIXED_RUNTIME_OUTPUT_DIRECTORY@\Release;@CURRENT_FIXED_BIN_DIRS@
@CURRENT_OUTPUT_NAME@.exe %*
pause