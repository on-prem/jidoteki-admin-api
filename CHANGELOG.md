# Changelog

## 1.24.0 (2019-11-05)

  ### Minor fixes

  * [api] Add audit logging and 2s pause between failed token updates
  * [api] Reorder some functions in the `core` api files
  * [deps] Update `jidoteki-admin` dep to v1.24.0

  ### New features

  * [api/frontend] Add _First Run_ setup process when first accessing the Admin Dashboard.
    On first run, the API will generate a random passphrase and store it in the 
    `api.token.setup` file. The passphrase uses 4 of 7776 words from the _EFF large wordlist_,
    thus providing ~51 bits of entropy. This _First Run_ feature is disabled by default and
    must be enabled by adding `"first-run":{"word-length":4,"enabled":true}` to 
    the `/usr/local/etc/jidoteki-admin-api.json` file.
  * [api] When _First Run_ is `enabled`, error responses now contain a `First-Run` key and boolean value

## 1.23.0 (2018-07-26)

  ### Bug fix

  * [api] Add bugfixes for endpoints with invalid responses. #38

## 1.22.1 (2018-06-30)

  ### Bug fix

  * [frontend] Fix regression, ensure /docs is read from a variable

## 1.22.0 (2018-06-29)

  ### Minor fixes

  * [api] Fix longstanding bug: stunnel starts regardless of the value of JIDO_WITH_SSL
  * [frontend] Generate static HTML help docs, without JavaScript
  * [deps] Update`jidoteki-admin` dep to v1.22.0
  * [deps] Remove 'strapdown' and 'google prettify' deps

## 1.21.1 (2018-03-10)

  ### Minor fixes

  * [frontend] Ensure progress bar is displayed while uploading files

## 1.21.0 (2018-03-07)

  ### New features

  * [api/frontend] Accept IPv6 addresses in Network settings
  * [api] Add audit logging to additional API endpoints
  * [api] Include update status percentage in "/update" endpoint
  * [frontend] Renamed 'Jidoteki' to 'On-Prem'

  ### Minor fixes

  * [deps] Remove `json, semver, unit` deps as direct dependencies, add `jidoteki-admin` as dependency
