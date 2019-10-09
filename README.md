# levurehelper-macos_notary
Levure helper for notarizing your macOS application during packaging

# Configure

`.env` needs `macos_notary_username=` which is set to the apple id. Optional `macos_notary_ascprovider=` key can be included.

Password can go in one of two places:
1. `.env` under `macos_notary_password=`
2. Keychain in key named `levure_macos_notary: APP_NAME` where `APP_NAME` is the `name` key from `app.yml` that has spaces replaced with "_".

Expects the app array to have the `macos dmg filename` key set. The dropDMG helper sets this.
