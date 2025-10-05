@echo off
REM Anomaly Detection Testing Script (Windows Batch Wrapper)
REM Task 11.4: Test anomaly detection

powershell -ExecutionPolicy Bypass -File "%~dp0test-anomaly-detection.ps1"
