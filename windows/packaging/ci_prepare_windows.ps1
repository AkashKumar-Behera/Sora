$pubCache = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"

# 1. Audiotags
$audioTagsDir = Get-ChildItem -Path $pubCache -Directory -Filter "audiotags*" | Select-Object -First 1
if ($audioTagsDir) {
  $audioTagsWin = Join-Path $audioTagsDir.FullName "windows"
  Write-Host "Downloading audiotags binary to $($audioTagsWin)..."
  Invoke-WebRequest -Uri "https://github.com/erikas-taroza/audiotags/releases/download/v1.4.2/windows.tar.gz" -OutFile "$audioTagsWin\windows.tar.gz"
  tar -xzf "$audioTagsWin\windows.tar.gz" -C "$audioTagsWin"
}

# 2. smtc_windows
$smtcDir = Get-ChildItem -Path $pubCache -Directory -Filter "smtc_windows*" | Select-Object -First 1
if ($smtcDir) {
  $smtcWin = Join-Path $smtcDir.FullName "windows"
  $smtcTargetDir = Join-Path $smtcWin "smtc_windows-v0.1.3"
  New-Item -ItemType Directory -Force -Path $smtcTargetDir | Out-Null
  Write-Host "Downloading smtc_windows binary to $($smtcWin)..."
  Invoke-WebRequest -Uri "https://github.com/KRTirtho/frb_plugins/releases/download/smtc_windows-v0.1.3/windows.tar.gz" -OutFile "$smtcWin\smtc_windows-v0.1.3.tar.gz"
  tar -xzf "$smtcWin\smtc_windows-v0.1.3.tar.gz" -C "$smtcTargetDir"

  # Clean static CMakeLists without inline heredoc issues
  $cmakeFile = Join-Path $smtcWin "CMakeLists.txt"
  $content = @(
    "cmake_minimum_required(VERSION 3.14)",
    "project(smtc_windows LANGUAGES CXX)",
    'set(LibraryVersion "smtc_windows-v0.1.3")',
    'set(LibRoot "${CMAKE_CURRENT_SOURCE_DIR}/${LibraryVersion}")',
    'set(smtc_windows_bundled_libraries',
    '  "${LibRoot}/${FLUTTER_TARGET_PLATFORM}/smtc_windows.dll"',
    '  PARENT_SCOPE',
    ')'
  )
  [System.IO.File]::WriteAllLines($cmakeFile, $content)
  Write-Host "smtc_windows CMakeLists.txt successfully patched!"
}
