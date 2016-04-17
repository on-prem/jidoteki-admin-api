> Return to the [Admin UI](/)

# API Documentation v1.10.0

All API calls are prefixed with `/api/v1/admin`

  1. Authentication
  2. Set the API token
  3. Change the API token
  4. Upload a license
  5. View the license details
  6. Update the system
  7. View the status of a software update
  8. View the software update log
  9. Update the network and application settings
  10. View the network and application settings
  11. Retrieve compressed log files
  12. Retrieve an encrypted debug bundle
  13. Retrieve the version of the system
  14. Retrieve the changelog of the system
  15. Upload and update TLS certificates
  16. View the status of a TLS certificate update
  17. Reboot the system


## 1. Authentication

There are two methods to perform authentication (Token and HMAC).

Each API request requires a valid API token or HMAC hash. One must be sent on every request as a query parameter.

> *You **MUST** _Set the API token_ prior to making any API calls.*

### Token-based authentication

Query parameter: `?token=yourtoken`, except for the initial **setup** API call.

### HMAC-based authentication

Query parameter: `?hash=sha256hash`

If using HMAC authentication, you must generate a signature following these steps:

1. Generate an SHA256 hash of your API token, ex:

```
echo -n "yourtoken" | openssl dgst -sha256
```

This should return the SHA256 hash, your new _secret key_:

```
13e2ff941bbc8692cad141c8d293dda2c4f1c1a3c51b93d54f1a1693e1206107
```

2. Concatenate the **HTTP Method** and **Endpoint**, and generate an SHA256 HMAC hash using your _secret key_, ex:

```
echo -n "GET/api/v1/admin/version" | openssl dgst -sha256 -hmac 13e2ff941bbc8692cad141c8d293dda2c4f1c1a3c51b93d54f1a1693e1206107
```

This should return the HMAC hash:

```
b714a60732e096ccef06e360eefe0f1ba4fa5d16ef7da726612e2026e5523241
```

3. Append the HMAC hash as a query parameter, ex:

```
GET /api/v1/admin/version?hash=b714a60732e096ccef06e360eefe0f1ba4fa5d16ef7da726612e2026e5523241
```

Using HMAC-based authentication, every API request will require a newly generated HMAC hash.

### 2. Set the API token

This is the initial **setup** API call where you set the API token.

**Endpoint**

```
POST /api/v1/admin/setup
```

**Parameters**

  * **newtoken**: **(required)** New API token sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/setup -F newtoken=yourtoken

HTTP/1.1 200 OK
Content-Type: application/json
{"Status":"200 OK"}
```

### 3. Change the API token

**Endpoint**

```
POST /api/v1/admin/setup
```

**Parameters**

  * **newtoken**: **(required)** New API token sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/setup?token=yourtoken -F newtoken=mynewtoken

HTTP/1.1 200 OK
Content-Type: application/json
{"Status":"200 OK"}
```

### 4. Upload a license

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

### 5. View the license details

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

### 6. Update the system

**Endpoint**

```
POST /api/v1/admin/update
```

**Parameters**

  * **update**: **(required)** Encrypted software update package sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/update?token=yourtoken -F update=@software_update-v1.2.0.enc

HTTP/1.1 202 Accepted
Location: /api/v1/admin/update
{"Status":"202 Accepted","Location":"/api/v1/admin/update"}
```

### 7. View the status of a software update

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
    "log": "[1432140922][SYSTEM] Updating system successful"
}
```

### 8. View the software update log

**Endpoint**

```
GET /api/v1/admin/update/log
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/update/log?token=yourtoken

HTTP/1.1 200 OK
Content-Type: text/plain
[1433080791][SYSTEM] Updating system. Please wait..
[1433080791][SYSTEM] Updating system successful
...
```

### 9. Update the network and application settings

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
{"Status":"202 Accepted","Location":"/api/v1/admin/settings"}
```

**Example static settings.json**

```
{
    "network": {
        "interface": "eth0",
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
        "interface": "eth0",
        "hostname": "test.host"
    },
    "app": {
        "name": "testapp"
    }
}
```

### 10. View the network and application settings

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
        "interface": "eth0",
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

### 11. Retrieve compressed log files

**Endpoint**

```
GET /api/v1/admin/logs
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/logs?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/octet-stream
Filename: logs.tar.gz
```

### 12. Retrieve an encrypted debug bundle

**Endpoint**

```
GET /api/v1/admin/debug
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/debug?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/octet-stream
Filename: debug-bundle.tar
```

### 13. Retrieve the version of the system

**Endpoint**

```
GET /api/v1/admin/version
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/version?token=yourtoken
or
curl -X GET https://enterprise.vm:8443/api/v1/admin/version?hash=b714a60732e096ccef06e360eefe0f1ba4fa5d16ef7da726612e2026e5523241

HTTP/1.1 200 OK
Content-Type: application/json
{
    "version": "1.0.0"
}
```

### 14. Retrieve the changelog of the system

**Endpoint**

```
GET /api/v1/admin/changelog
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/changelog?token=yourtoken

HTTP/1.1 200 OK
Content-Type: text/plain
# Changelog

## 1.0.9 (2015-08-21)

  * Update app to version 2.1.2
  * Update nodejs modules
  * Update system packages
  * Update API to version 1.1.6
```

### 15. Upload and update TLS certificates

**Endpoint**

```
POST /api/v1/admin/certs
```

**Parameters**

  * **public**: **(required)** Public TLS certificate (PEM format) sent as `multipart/form-data`
  * **private**: **(required)** Private TLS certificate key (unencrypted RSA format) sent as `multipart/form-data`
  * **ca**: **(optional)** Intermediate or Root TLS certificate (PEM format) sent as `multipart/form-data`

**Example**

```
curl -X POST https://enterprise.vm:8443/api/v1/admin/certs?token=yourtoken -F public=@enterprise.vm.pem -F private=@enterprise.vm.key -F ca=@enterprise-ca.pem

HTTP/1.1 202 Accepted
Location: /api/v1/admin/certs
{"Status":"202 Accepted","Location":"/api/v1/admin/certs"}
```

### 16. View the status of a TLS certificate update

**Endpoint**

```
GET /api/v1/admin/certs
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/certs?token=yourtoken

HTTP/1.1 200 OK
Content-Type: application/json
{
    "log": "[1459884203][SYSTEM] Validating and adding TLS certificates"
}
```

### 17. Reboot the system

**Endpoint**

```
GET /api/v1/admin/reboot
```

**Example**

```
curl -X GET https://enterprise.vm:8443/api/v1/admin/reboot?token=yourtoken

HTTP/1.1 202 Accepted
Content-Type: application/json
{"Status": "202 Accepted"}
```

**Powered by [Jidoteki](https://jidoteki.com) - [Copyright notices](docs/NOTICE)**
