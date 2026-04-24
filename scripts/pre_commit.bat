@echo off
setlocal

echo [1/3] Fixing Spaces and Formatting...
:: This will actually overwrite files to fix spacing
call dart format .

echo [2/3] Checking for code issues (Depth, Complexity, Errors)...
:: This will check for linter warnings and errors
call flutter analyze
if %errorlevel% neq 0 (
    echo.
    echo [!] ERROR: Code analysis failed. 
    echo Please fix the warnings/errors above before you commit.
    exit /b %errorlevel%
)

echo [3/3] Success! Your code is ready to be committed.
echo.
echo TIP: If a function was warned about complexity, consider breaking it into smaller functions.
endlocal
