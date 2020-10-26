Name "NoRV Client"
OutFile "NoRV Client Installer 1.6.exe"
RequestExecutionLevel admin
Unicode True
InstallDir "$LocalAppdata\NoRV Client"
InstallDirRegKey HKLM "Software\NoRV Client" "Install_Dir"

!include MUI.nsh
!include nsDialogs.nsh
!include ReplaceInFile.nsh

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom logPathPage
Page custom videoPathPage
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

UninstPage uninstConfirm
UninstPage instfiles

Var LogPath
Var VideoPath

Section "NoRV Client"
  SectionIn RO
  
  SetOutPath $INSTDIR
  File /r "..\NoRV_Client\bin\Install\"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  !insertmacro _ReplaceInFile "$INSTDIR\Config.xml" "#LogPath#" $LogPath
  !insertmacro _ReplaceInFile "$INSTDIR\Config.xml" "#VideoPath#" $VideoPath
  Delete "$INSTDIR\Config.xml.old"
  
  WriteRegStr HKLM "SOFTWARE\NoRV Client" "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "DisplayName" "NoRV Client 1.6"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "DisplayIcon" '"$INSTDIR\NoRV Client.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "DisplayVersion" "1.6.1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "InstallLocation" '"$INSTDIR"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "Publisher" "NoRV"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "NoRepair" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "VersionMajor" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client" "VersionMinor" 6

  ; Startup Shortcut
  CreateShortcut "$SMPROGRAMS\Startup\NoRV Client.lnk" "$INSTDIR\NoRV Client.exe"
SectionEnd

Section "WebServer Configuration"
  nsExec::Exec 'netsh http delete urlacl url=http://*:80/'
  nsExec::Exec 'netsh http add urlacl url=http://*:80/ user=Everyone'
SectionEnd

Section "Start Menu Shortcuts"
  CreateDirectory "$SMPROGRAMS\NoRV Client"
  CreateShortcut "$SMPROGRAMS\NoRV Client\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\NoRV Client\NoRV Client.lnk" "$INSTDIR\NoRV Client.exe"
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NoRV Client"
  DeleteRegKey HKLM "SOFTWARE\NoRV Client"

  RMDir /r "$SMPROGRAMS\NoRV Client"
  Delete "$SMPROGRAMS\Startup\NoRV Client.lnk"
  Delete "$SMPROGRAMS\Startup\NGINX.lnk"
  RMDir /r "$INSTDIR"

  nsExec::Exec 'netsh http delete urlacl url=http://*:80/'
SectionEnd

Var LogPathEdit
Var LogPathBtn
Function logPathPage
  !insertmacro MUI_HEADER_TEXT "Choose Log Location" "Choose the folder in which to save logs."
  nsDialogs::Create 1018
  ${NSD_CreateGroupBox} 0 113 100% 34u "Log Folder"
  nsDialogs::CreateControl EDIT ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}|${ES_AUTOHSCROLL}|${WS_TABSTOP} ${WS_EX_CLIENTEDGE} 3% 138 70% 12u $LogPath
  ${If} $LogPath == ""
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 0
  ${EndIf}
  Pop $LogPathEdit
  ${NSD_CreateButton} 76% 135 20% 15u "&Browse..."
  Pop $LogPathBtn
  GetFunctionAddress $0 logPathBrowse
  nsDialogs::OnClick $LogPathBtn $0
  nsDialogs::Show
FunctionEnd
Function logPathBrowse
  nsDialogs::SelectFolderDialog "Choose Log Location" "$DOCUMENTS"
  Pop $LogPath
  ${If} $LogPath != "error"
    ${NSD_SetText} $LogPathEdit "$LogPath"
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 1
  ${EndIf}
FunctionEnd

Var VideoPathEdit
Var VideoPathBtn
Function videoPathPage
  !insertmacro MUI_HEADER_TEXT "Choose Video Location" "Choose the folder in which to save videos."
  nsDialogs::Create 1018
  ${NSD_CreateGroupBox} 0 113 100% 34u "Video Folder"
  nsDialogs::CreateControl EDIT ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}|${ES_AUTOHSCROLL}|${WS_TABSTOP} ${WS_EX_CLIENTEDGE} 3% 138 70% 12u $VideoPath
  ${If} $VideoPath == ""
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 0
  ${EndIf}
  Pop $VideoPathEdit
  ${NSD_CreateButton} 76% 135 20% 15u "&Browse..."
  Pop $VideoPathBtn
  GetFunctionAddress $0 videoPathBrowse
  nsDialogs::OnClick $VideoPathBtn $0
  nsDialogs::Show
FunctionEnd
Function videoPathBrowse
  nsDialogs::SelectFolderDialog "Choose Video Location" "$DOCUMENTS"
  Pop $VideoPath
  ${If} $VideoPath != "error"
    ${NSD_SetText} $VideoPathEdit $VideoPath
    GetDlgItem $0 $HWNDPARENT 1
    EnableWindow $0 1
  ${EndIf}
FunctionEnd