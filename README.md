# dropDMG helper

Levure helper that uses [DropDMG](https://c-command.com/dropdmg/) to create a DMG of your macOS application when packaging your application.

```
# app.yml

dropDMG:
  path: /usr/bin/local/dropdmg
  format: bzip2
  layout name:
  license name:
```

```
# app.yml

build profiles:
  ...
  release:
    dropDMG:
      name: My App
  beta:
    dropDMG:
      name: My App Beta
  ...
```
