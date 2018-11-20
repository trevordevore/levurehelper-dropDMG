script "dropDMG Packager"
command packagingComplete pBuildProfile, pOutputFolder

  if the platform is not "macos" then return empty

  local tSettingsA, tProfilesA, tName, tLayoutSourceFolder

  put levureAppGet("dropDMG", true) into tSettingsA

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
  local tVolumeName, tFile, tCmd, tResult, tReturnVal

  put DropDMGVolumeName(pOutputFolder) into tVolumeName
  put DropDMGLayoutSourceFolder(pOutputFolder) into tLayoutSourceFolder

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
  put format(" --volume-name=\"%s\" --base-name=\"%s\" -o \"%s\" \"%s\"", tVolumeName, tFile, pOutputFolder, tLayoutSourceFolder) after tCmd
  put shell(tCmd) into tResult
  put the result into tReturnVal

  if tReturnVal is not empty then
    answer error "dropdmg reported an error in" && param(0) && "[" & textDecode(tResult, "utf8") & "]"
  end if
end packagingComplete


private function DropDMGLayoutSourceFolder pBuildFolder
  return pBuildFolder & "/macos"
end DropDMGLayoutSourceFolder


private function DropDMGVolumeName pBuildFolder
  local tMacFolder, tMacApp

  put pBuildFolder & "/macos" into tMacFolder

  put folders(tMacFolder) into tMacApp
  filter tMacApp with "*.app"

  if tMacApp is not empty then
    set the itemdelimiter to "."
    return item 1 to -2 of tMacApp
  else
    return empty
  end if
end DropDMGVolumeName
