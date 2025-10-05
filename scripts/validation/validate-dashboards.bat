@echo off
REM Dashboard Validation Script (Windows Batch Wrapper)
REM Task 11.3: Validate dashboards and visualizations

powershell -ExecutionPolicy Bypass -File "%~dp0validate-dashboards.ps1"
