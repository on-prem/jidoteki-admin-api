# Jidoteki Admin REST API

[![GitHub release](https://img.shields.io/github/release/unscramble/jidoteki-admin-api.svg)](https://github.com/unscramble/jidoteki-admin-api) [![Build Status](https://travis-ci.org/unscramble/jidoteki-admin-api.svg?branch=master)](https://travis-ci.org/unscramble/jidoteki-admin-api) [![Dependency](https://img.shields.io/badge/[deps] picolisp--json-v1.PicoLisp 32-bit or 64-bit v3.1.10.2+1.0-ff69b4.svg)](https://github.com/aw/picolisp-json) [![Dependency](https://img.shields.io/badge/[deps] picolisp--unit-v1.0.0-ff69b4.svg)](https://github.com/aw/picolisp-unit.git)

This API enables simple management of a [Jidoteki](https://jidoteki.com) Virtual Appliance.

In combination with the [jidoteki-admin](https://github.com/unscramble/jidoteki-admin), it is possible to use the REST API to:

  * Upload and validate a license file
  * Upload a software update package
  * View the status of a software update
  * View and update network settings
  * View and update application settings
  * Retrieve compressed log files
  * Retrieve version and changelog of the appliance

# Requirements

  * PicoLisp 32-bit or 64-bit v3.1.10.2+
  * Git
  * UNIX/Linux development/build tools (gcc, make/gmake, etc..)
  * Stunnel4 (for HTTPS only)
  * _(optional)_ `jidoteki-admin` deployment in `/opt/jidoteki/admin/`

# Getting started

  1. Type `make` to pull and compile the dependencies
  2. Type `./run.l` to launch the HTTP listener
  3. View the API documentation at: `http://enterprise.vm:8080` or `https://enterprise.vm:8443`

# File and directory permissions

The API does not need to run as root.

If using the [jidoteki-admin](https://github.com/unscramble/jidoteki-admin), it requires `sudo` access to commands in `/opt/jidoteki/admin/bin`, write access to `/opt/jidoteki/admin/home/sftp/uploads`, and read access to files in `/opt/jidoteki/admin/etc/`.

# Environment variables

It is possible to specify a few environment variables at runtime.

### JIDO_API_VERSION

There is only one API version (`1`), but this makes it possible to load a completely different set of API endpoints, ex: `JIDO_API_VERSION=2 ./run.l`.

### JIDO_API_PORT

The default port for the HTTP listener is `8080`.

### JIDO_WITH_SSL

By default, only the HTTP listener will be launched. If you want to start an HTTPS server as well, you can set `JIDO_WITH_SSL=true`.

It will launch an `stunnel4` process on port `8443`, so ensure an `enterprise.pem` SSL certificate exists in the same directory as `stunnel.conf`.

### JIDO_STUNNEL_BIN

The full path to the `stunnel4` binary. On CentOS it's `/usr/bin/stunnel`, but on Debian it's `/usr/bin/stunnel4`. Defaults to `/usr/bin/stunnel4`.

### JIDO_ADMIN_PATH

The full path to the Admin application. In most cases it refers to `/opt/jidoteki/admin/`, but it may be different depending on the application.

# API Endpoints

See the [API Documentation](docs/API.md).

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/unscramble/jidoteki-admin-api/issues/new).

If you want to improve this application, please make a pull-request.

# License

[MPL-2.0 License](LICENSE)

Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
