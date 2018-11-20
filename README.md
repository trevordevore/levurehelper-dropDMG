# dropDMG helper

[DropDMG](https://c-command.com/dropdmg/) is an application that creates DMG files for macOS.  It uses the `dropdmg` command line utility to combine your packaged macOS application into a DMG for distribution. You can optionally specify a layout and license file that you have created in DropDMG.

This helper runs when you package your Levure application and will place the resulting DMG file in package folder alongside the `macos` folder.

## Contents

* [Activate the dropDMG framework helper](#activate-the-dropdmg-framework-helper)
* [Setting up DropDMG](#setting-up-dropdmg)
* [Configuring settings for the helper](#configuring-settings-for-the-helper)
* [Specifying the name of the DMG file](#specifying-the-name-of-the-dmg-file)

## Activate the dropDMG framework helper

To add the dropDMG helper to your application you must download it and add the `dropDMG` folder to your application `helpers` folder.

Click on the green **Clone or download** button on the GitHub page and select **Download ZIP** from the menu that appears. Grab the folder from the archive and rename it to `dropDMG`. Add the renamed folder to your application `helpers` folder.

## Setting up DropDMG

Before using the dropDMG helper you need to set up DropDMG by doing the following:

1. Install the command line tool: https://c-command.com/dropdmg/manual#command-line-tool
2. Create a layout: https://c-command.com/dropdmg/manual#layouts
3. Add a license: https://c-command.com/dropdmg/manual#licenses

## Configuring settings for the helper

Now that DropDMG is set up you can to tell the helper the [format](https://c-command.com/dropdmg/manual#format) for the DMG file, the `layout name`, the `license name`, and the `volume name`. All of these settings are optional. If the `volume name` is empty then the application bundle name minus the `.app` extension will be used as the volume name.

For a list of acceptable `format` values type `man dropdmg` in a Terminal window. 

You can also provide the path to the `dropdmg` command line tool if for some reason you need to. This shouldn't be required though.

```
# app.yml

dropDMG:
  format: bzip2
  layout name: My App Layout
  license name: My App License
  volume name: My App
  path: /usr/bin/local/dropdmg
```

## Specifying the name of the DMG file

The name of the DMG file is configured in the build profiles section so that you can specify a different name based on the build profile. The following example shows how to use a different name for `release` and for `beta`.

```
# app.yml

build profiles:
  ...
  release:
    installer name:
      # Name to use for the DMG that will be created
      all platforms: My App
  beta:
    installer name:
      # Name to use for the DMG that will be created
      all platforms: My App Beta
  ...
```

Note that `installer name` is a generic name intended to be shared by other helpers that work with installers. For example, the Auto Updater helper uses `installer name` as does the Inno Setup helper. If you want to use a different name for `macOS` then use the `macos` key rather than the `all platforms` key.

## Adding additional files to the DMG

In DropDMG you can add additional files to your layout. When creating the DMG DropDMG will use the source folder in order to locate these additional files. When the dropDMG helper calls the dropdmg command line tool it sets the `macos` folder as the source folder. In order to copy additional files into the `macos` folder when you package your application you can add file copy opertaions to the `copy files` > `package folder` section of the `app.yml` file.

Here is an example that copies two files into the `macos` folder. In this example the `build files` folder where `instructions.rtf` and `graphic file.jpg` come from was created alongside the `app` and `levure` folders.

```
build profiles:
  all profiles:
    copy files:
      package folder:
        - filename: ../build files/instructions.rtf
          destination: macos
        - filename: ../build files/graphic file.jpg
          destination: macos
```          
