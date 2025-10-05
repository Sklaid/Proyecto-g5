@echo off
REM End-to-End Stack Validation Script (Windows Batch Wrapper)
REM Task 11.1: Deploy complete stack locally with Docker Compose

powershell -ExecutionPolicy Bypass -File "%~dp0validate-stack.ps1"
