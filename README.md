# Jidoteki Admin REST API

[![GitHub release](https://img.shields.io/github/release/unscramble/jidoteki-admin-api.svg)](https://github.com/unscramble/jidoteki-admin-api) [![Build Status](https://travis-ci.org/unscramble/jidoteki-admin-api.svg?branch=master)](https://travis-ci.org/unscramble/jidoteki-admin-api) [![Dependency](https://img.shields.io/badge/[deps] picolisp--json-v0.6.2-ff69b4.svg)](https://github.com/aw/picolisp-json) [![Dependency](https://img.shields.io/badge/[deps] picolisp--unit-v0.6.2-ff69b4.svg)](https://github.com/aw/picolisp-unit.git)

This API enables simple management of a [Jidoteki](https://jidoteki.com) Virtual Appliance.

In combination with the [jidoteki-admin](https://github.com/unscramble/jidoteki-admin), it is possible to use the REST API to:

  * Upload and validate a license file
  * Upload a software update package
  * View the status of a software update
  * View and update network settings
  * View and update application settings

# Requirements

  * PicoLisp 64-bit v3.1.9+
  * Git
  * UNIX/Linux development/build tools (gcc, make/gmake, etc..)
  * Stunnel4 (for HTTPS only)
  * `jidoteki-admin` deployment in `/opt/jidoteki/admin/`

# Getting started

  1. Type `make` to pull and compile the dependencies
  2. Type `./run.l` to launch the HTTP listener

# File and directory permissions

The API does not need to run as root.

It requires `sudo` access to commands in `/opt/jidoteki/admin/bin`, write access to `/opt/jidoteki/admin/home/sftp/uploads`, and read access to files in `/opt/jidoteki/admin/etc/`.

# Environment variables

It is possible to specify a few environment variables at runtime.

### JIDO_API_VERSION

There is only one API version (`1`), but this makes it possible to load a completely different set of API endpoints, ex: `JIDO_API_VERSION=2 ./run.l`.

### JIDO_API_PORT

The default port for the HTTP listener is `8080`.

### JIDO_WITH_SSL

By default, only the HTTP listener will be launched. If you want to start an HTTPS server as well, you can set `JIDO_WITH_SSL=true`.

It will launch an `stunnel4` process on port `8443`, so ensure an `enterprise.pem` SSL certificate exists in the same directory as `stunnel.conf`.

# API Endpoints

All API calls are prefixed with `/api/v1/admin`.

  1. [Authentication](#authentication)
  2. [Set the API token and upload a license](#set-the-API-token-and-upload-a-license)
  3. [View the license details](#view-the-license-details)
  4. [Update the virtual appliance](#update-the-virtual-appliance)
  5. [View the status of a software update](#view-the-status-of-a-software-update)
  6. [View the software update log](#view-the-software-update-log)
  7. [Update the network and application settings](#update-the-network-and-application-settings)
  8. [View the network and application settings](#view-the-network-and-application-settings)

### Authentication

Each API request requires a valid API token. The API token must be sent on every request as a query parameter: `?token=yourtoken`. The token can only be set once, when uploading a valid license file.

> You **MUST** set the API token and upload a valid license prior to making any other API calls.

### Set the API token and upload a license

This API call allows you to perform two tasks at once:

  1. Set the API token
  2. Upload a license

**Endpoint**

```
POST /api/v1/admin/license
```

**Parameters**

  * **license**: **(required)** Encrypted license file sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/license?token=yourtoken -F license=@license.asc

HTTP/1.1 200 OK
Content-Type: application/json
{
    "app": "enterprise",
    "users": 20,
    "expires": "19 January 2038",
    "name": "Enterprise Company",
    "contact": "cto@enterprise"
}
```

### View the license details

**Endpoint**

```
GET /api/v1/admin/license
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/license?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/json
{
    "app": "enterprise",
    "users": 20,
    "expires": "19 January 2038",
    "name": "Enterprise Company",
    "contact": "cto@enterprise"
}
```

### Update the virtual appliance

**Endpoint**

```
POST /api/v1/admin/update
```

**Parameters**

  * **update**: **(required)** Encrypted software update package sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/update?token=yourtoken -F update=@software_update-v1.2.0.asc

HTTP/1.1 202 Accepted
Location: /api/v1/admin/update
```

### View the status of a software update

**Endpoint**

```
GET /api/v1/admin/update
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/update?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "success",
    "log": "[1432140922][VIRTUAL APPLIANCE] Updating virtual appliance successful"
}
```

### View the software update log

**Endpoint**

```
GET /api/v1/admin/update/log
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/update/log?token=yourtoken

HTTP/1.1 200 OK
Content-Type: text/plain
[1433080791][VIRTUAL APPLIANCE] Updating virtual appliance. Please wait..
[1433080791][VIRTUAL APPLIANCE] Updating virtual appliance successful
...
```

### Update the network and application settings

**Endpoint**

```
POST /api/v1/admin/settings
```

**Parameters**

  * **settings**: **(required)** JSON settings file sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/settings?token=yourtoken -F settings=@settings.json

HTTP/1.1 202 Accepted
Location: /api/v1/admin/settings
```

**Example static settings.json**

```
{
    "network": {
        "hostname": "test.host",
        "ip_address": "192.168.1.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.1.1",
        "dns1": "192.168.1.2",
        "dns2": "192.168.1.3"
    },
    "app": {
        "name": "testapp"
    }
}
```

Simply omit the `ip_address, netmask, gateway` fields and the network will be reconfigured using DHCP.

**Example dhcp settings.json**

```
{
    "network": {
        "hostname": "test.host"
    },
    "app": {
        "name": "testapp"
    }
}
```

### View the network and application settings

**Endpoint**

```
GET /api/v1/admin/settings
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/settings?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/json
{
    "network": {
        "hostname": "test.host",
        "ip_address": "192.168.1.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.1.1",
        "dns1": "192.168.1.2",
        "dns2": "192.168.1.3"
    },
    "app": {
        "name": "testapp"
    }
}
```

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/unscramble/jidoteki-admin-api/issues/new).

If you want to improve this library, please make a pull-request.

# License

[MPL-2.0 License](LICENSE)

Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
