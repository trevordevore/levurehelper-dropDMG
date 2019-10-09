script "macOS Notary Packager"

/**
Summary: Update localization folders with ISO naming scheme.

*/
command finalizePackageForPlatform pBuildProfile, pPlatform, pAppA, pAppFolder, pOutputFolder
  local tFile, tData, tBuildProfile, tURL

  switch pPlatform
    case "macos"
      _standardizeLocalizationFolderNames pOutputFolder & "/" & levureStandaloneName()
      break
  end switch
end finalizePackageForPlatform


/**
Summary: Summary

*/
command packagingComplete pBuildProfile, pOutputFolder, pAppA
  if the platform is not "macos" then return empty
  if there is not a file pAppA["macos dmg filename"] then
    answer error "macOS Notary error: No path to DMG file provided."
    return empty
  end if

  local tCmd, tPrimaryId, tEnvA, tResult, tReturnVal

  put levureAppGetENV() into tEnvA

  put pAppA["name"] && pAppA["version"] & "." & pAppA["build"] into tPrimaryId
  replace space with "-" in tPrimaryId

  if tEnvA["macos_notary_password"] is empty then
    local tKeyChainName

    put pAppA["name"] into tKeyChainName
    replace space with "-" in tKeyChainName
    put tolower(tKeyChainName) into tKeyChainName

    put "levure_macos_notary: " before tKeyChainName
    put format("@keychain:" & tKeyChainName) into tEnvA["macos_notary_password"]
  end if

  put "xcrun altool -type osx --notarize-app" into tCmd
  put format(" --primary-bundle-id \"%s\"", tPrimaryId) after tCmd
  put format(" --username \"%s\"", tEnvA["macos_notary_username"]) after tCmd
  put format(" --password \"%s\"", tEnvA["macos_notary_password"]) after tCmd
  put format(" --file \"%s\"", pAppA["macos dmg filename"]) after tCmd
  if tEnvA["macos_notary_ascprovider"] is not empty then
    put format(" --ascprovider \"%s\"", tEnvA["macos_notary_ascprovider"]) after tCmd
  end if

  dispatch "packagerLog" to stack "Levure Framework Application Packager" with "macos-notary shell command:" && tCmd
  put shell(tCmd) into tResult
  put the result into tReturnVal

  if tReturnVal is not empty then
    answer error "macOS Notary reported an error in" && param(0) && "[" & textDecode(tResult, "utf8") & "]"
  end if
end packagingComplete


/*
xcrun altool -type osx --notarize-app result:

2019-10-09 00:01:32.958 altool[27575:455061] No errors uploading '/Users/trevordevore/Development/screensteps-4/builds/beta/4.1.1-556/ScreenSteps Beta 4.1.1-556.dmg'.
RequestUUID = 3da8fdf4-0c86-46fd-b72e-338983d9dafc
*/

/*
xcrun altool --notarization-info success result:

2019-10-09 00:06:39.966 altool[27819:476350] No errors getting notarization info.

   RequestUUID: 3da8fdf4-0c86-46fd-b72e-338983d9dafc
          Date: 2019-10-09 05:01:33 +0000
        Status: success
    LogFileURL: https://osxapps-ssl.itunes.apple.com/itunes-assets/Enigma113/v4/ca/b3/36/cab33654-ead9-c42e-050f-59c90ba608d1/developer_log.json?accessKey=1570791999_8603781023417794841_ssZw1f28ESDK9aCwCFA%2B1%2B7qn8yxbwixyhDxQCT%2Bs9%2FFPG7U4kBIbmVm2G0TQRF%2Bl%2FtB1SmolZ%2BGraXIsRNFEjJIE8bTUgHGCKWn1p%2Bhzq53R74CVC%2BOY3JhkhzdrgkLbZXv%2FGTwmBPCqcZs0jb%2BulioPCU2FvfVMFdxgCFZ%2F1g%3D
   Status Code: 0
Status Message: Package Approved
*/


/**
Summary: Replaces .lproj folders with

Returns: nothing
*/
private command _standardizeLocalizationFolderNames pAppBundleFolder
  local tError, tRsrcFolder, tFolders, tFolder
  local tNewFolder, tLocalesA

  put pAppBundleFolder & "/Contents/Resources" into tRsrcFolder

  put folders(tRsrcFolder) into tFolders
  filter tFolders with "*.lproj"

  put _localizationLookup() into tLocalesA

  set the itemDelimiter to "."

  repeat for each line tFolder in tFolders
    if item 1 of tFolder is among the keys of tLocalesA then
      put tFolder into tNewFolder
      put tLocalesA[item 1 of tFolder] into item 1 of tNewFolder
      rename (tRsrcFolder & "/" & tFolder) to (tRsrcFolder & "/" & tNewFolder)
      put the result into tError
    end if

    if tError is not empty then next repeat
  end repeat

  return tError
end _standardizeLocalizationFolderNames


private function _localizationLookup
  local tA

  put "nl" into tA["Dutch"]
  put "en" into tA["English"]
  put "fr" into tA["French"]
  put "de" into tA["German"]
  put "it" into tA["Italian"]
  put "jp" into tA["Japanese"]
  put "es" into tA["Spanish"]

  return tA
end _localizationLookup
