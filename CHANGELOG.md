# Changelog

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
