@echo off
REM Alerting Rules Testing Script (Windows Batch Wrapper)
REM Task 11.5: Test alerting rules

powershell -ExecutionPolicy Bypass -File "%~dp0test-alerting.ps1"
