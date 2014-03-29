# define name of installer
outFile "Install Eggz.exe"
 
# define installation directory
installDir "$PROGRAMFILES\Eggz"

#overwrite 
SetOverwrite on
 
# for removing Start Menu shortcut in Windows 7
RequestExecutionLevel admin
 
# start default section
section
 
    # set the installation directory as the destination for the following actions
    setOutPath $INSTDIR

    # list of files to install
    File eggz.exe
    File DevIL.dll
    File love.dll
    File lua51.dll
    File mpg123.dll
    File msvcp110.dll
    File msvcr110.dll
    File OpenAL32.dll
    File SDL2.dll

    # create the uninstaller
    writeUninstaller "$INSTDIR\Uninstall Eggz.exe"

    # create start menu shortcuts
    createShortCut "$SMPROGRAMS\Uninstall Eggz.lnk" "$INSTDIR\Uninstall Eggz.exe"
    createShortCut "$SMPROGRAMS\Play Eggz.lnk" "$INSTDIR\eggz.exe"

    # create desktop shortcuts
    createShortCut "$DESKTOP\Play Eggz.lnk" "$INSTDIR\eggz.exe"
    
sectionEnd
 
# uninstaller section start
section "uninstall"
 
    # list of files to install
    delete "$INSTDIR\eggz.exe"
    delete "$INSTDIR\DevIL.dll"
    delete "$INSTDIR\love.dll"
    delete "$INSTDIR\lua51.dll"
    delete "$INSTDIR\mpg123.dll"
    delete "$INSTDIR\msvcp110.dll"
    delete "$INSTDIR\msvcr110.dll"
    delete "$INSTDIR\OpenAL32.dll"
    delete "$INSTDIR\SDL2.dll"

    # remove desktop shortcuts
    delete "$DESKTOP\Play Eggz.lnk"
 
    # remove the links from the start menu
    delete "$SMPROGRAMS\Uninstall Eggz.lnk"
    delete "$SMPROGRAMS\Play Eggz.lnk"

    # delete the uninstaller
    delete "$INSTDIR\Uninstall Eggz.exe"
 
# uninstaller section end
sectionEnd