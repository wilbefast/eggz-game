# define name of installer
outFile "Install Eggz.exe"
 
# define installation directory
installDir "$PROGRAMFILES\Eggz"
 
# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel user
 
# start default section
section
 
    # set the installation directory as the destination for the following actions
    setOutPath $INSTDIR

    # list of files to install
    File Eggz.exe
    File DevIL.dll
    File liblove.dll
    File lua51.dll
    File mpg123.dll
    File msvcp100.dll
    File OpenAL.dll
    File SDL.dll

    # create the uninstaller
    writeUninstaller "$INSTDIR\Uninstall Eggz.exe"

    # create start menu shortcuts
    createShortCut "$SMPROGRAMS\Uninstall Eggz.lnk" "$INSTDIR\Uninstall Eggz.exe"
    createShortCut "$SMPROGRAMS\Play Eggz.lnk" "$INSTDIR\Eggz.exe"

    # create desktop shortcuts
    createShortCut "$DESKTOP\Play Eggz.lnk" "$INSTDIR\Eggz.exe"
    
sectionEnd
 
# uninstaller section start
section "uninstall"
 
    # list of files to install
    delete "$INSTDIR\Eggz.exe"
    delete "$INSTDIR\DevIL.dll"
    delete "$INSTDIR\liblove.dll"
    delete "$INSTDIR\lua51.dll"
    delete "$INSTDIR\mpg123.dll"
    delete "$INSTDIR\msvcp100.dll"
    delete "$INSTDIR\OpenAL.dll"
    delete "$INSTDIR\SDL.dll"

    # remove desktop shortcuts
    delete "$DESKTOP\Play Eggz.lnk"
 
    # remove the links from the start menu
    delete "$SMPROGRAMS\Uninstall Eggz.lnk"
    delete "$SMPROGRAMS\Play Eggz.lnk"

    # delete the uninstaller
    delete "$INSTDIR\Uninstall Eggz.exe"
 
# uninstaller section end
sectionEnd