script "dropDMG Packager"
command packagingComplete pBuildProfile, pOutputFolder

  if the platform is not "macos" then return empty

  local tSettingsA, tProfilesA, tName, tMacAppBundleFolder

  if levureAppHasProperty("dropDMG") then
    put levureAppGet("dropDMG") into tSettingsA
  end if

  if tSettingsA is not an array then
    # TODO: Figure out error reporting
    return empty
  end if

  # Only build if a name has been set
  put levureAppGet("build profiles") into tProfilesA

  put tProfilesA[pBuildProfile]["installer name"]["macos"] into tName
  if tName is empty then
    put tProfilesA["all profiles"]["installer name"]["macos"] into tName
  end if
  if tName is empty then
    put tProfilesA[pBuildProfile]["installer name"]["all platforms"] into tName
  end if
  if tName is empty then
    put tProfilesA["all profiles"]["installer name"]["all platforms"] into tName
  end if

  # TODO: Figure out error reporting
  if tName is empty then return empty

  # Have a name so create DMG
  local tFile, tCmd, tResult, tReturnVal

  put MacAppBundleFolder(pOutputFolder) into tMacAppBundleFolder

  put tName && levureAppGet("version") & "-" & levureAppGet("build") & ".dmg" into tFile

  if tSettingsA["path"] is empty then put "/usr/local/bin/dropdmg" into tSettingsA["path"]
  if tSettingsA["format"] is empty then put "bzip2" into tSettingsA["format"]

  # Create DMG using DropDMG
  put format("\"%s\" --format=\"%s\"", tSettingsA["path"], tSettingsA["format"]) into tCmd

  if tSettingsA["layout name"] is not empty then
    put format(" --layout-name=\"%s\"", tSettingsA["layout name"]) after tCmd
  end if
  if tSettingsA["license name"] is not empty then
    put format(" --license-name=\"%s\"", tSettingsA["license name"]) after tCmd
  end if
  put format(" --base-name=\"%s\" -o \"%s\" \"%s\"", tFile, pOutputFolder, tMacAppBundleFolder) after tCmd
  put shell(tCmd) into tResult
  put the result into tReturnVal

  if tReturnVal is not empty then
    answer error "dropdmg reported an error in" && param(0) && "[" & textDecode(tResult, "utf8") & "]"
  end if
end packagingComplete


private function MacAppBundleFolder pBuildFolder
  local tMacFolder, tMacApp

  put pBuildFolder & "/macos" into tMacFolder

  put folders(tMacFolder) into tMacApp
  filter tMacApp with "*.app"

  if tMacApp is not empty then
    return tMacFolder & "/" & tMacApp
  else
    return empty
  end if
end MacAppBundleFolder
