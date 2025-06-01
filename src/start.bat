@echo off
cd /d %~dp0

start bin\lua54.exe lua\start_helper.lua
exit