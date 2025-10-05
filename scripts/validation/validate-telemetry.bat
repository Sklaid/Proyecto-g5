@echo off
REM Telemetry Pipeline Validation Script (Windows Batch Wrapper)
REM Task 11.2: Validate telemetry pipeline

powershell -ExecutionPolicy Bypass -File "%~dp0validate-telemetry.ps1"
