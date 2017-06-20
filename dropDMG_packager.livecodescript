script "dropDMG Packager"
command postPackagForBuildProfile pBuildProfile, pOutputFolder
  local tSettingsA, tProfilesA, tName, tMacAppBundleFolder

  if levureAppHasProperty("dropDMG") then
    put levureAppGet("dropDMG") into tSettingsA
    if tSettingsA is not an array then
      # TODO: Figure out error reporting
      return empty
    end if
  end if

  # Only build if a name has been set
  put levureAppGet("build profiles") into tProfilesA
  put tProfilesA[pBuildProfile]["dropDMG"]["name"] into tName
  if tName is empty then
    put tProfilesA["all profiles"]["dropDMG"]["name"] into tName
  end if
  # TODO: Figure out error reporting
  if tName is empty then return empty

  # Have a name so create DMG
  local tFile, tCmd

  put MacAppBundleFolder(pOutputFolder) into tMacAppBundleFolder

  put tName && levureAppGet("version") & "-" & levureAppGet("build") & ".dmg" into tFile

  if tSettingsA["path"] is empty then put "/usr/local/bin/dropdmg" into tSettingsA["path"]
  if tSettingsA["format"] is empty then put "bzip2" into tSettingsA["format"]

  # Create DMG using DropDMG
  put format("\"%s\" --format=\"%s\" --layout-name=\"%s\" --license-name=\"%s\" --base-name=\"%s\" -o \"%s\" \"%s\"", \
        tSettingsA["path"], tSettingsA["format"], tSettingsA["layout name"], tSettingsA["license name"], tFile, pOutputFolder, tMacAppBundleFolder) into tCmd
  get shell(tCmd)
  put "dropdmg return:" && it
end postPackagForBuildProfile


private function MacAppBundleFolder pBuildFolder
  local tMacFolder

  put "macos" into tMacFolder

  if there is a folder (pBuildFolder & "/" & tMacFolder & "/ScreenSteps.app") then
    return pBuildFolder & "/" & tMacFolder & "/ScreenSteps.app"
  else
    return pBuildFolder & "/" & tMacFolder & "/ScreenSteps Beta.app"
  end if
end MacAppBundleFolder
