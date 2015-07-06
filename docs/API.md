# API Documentation

All API calls are prefixed with `/api/v1/admin`

  1. Authentication
  2. Set the API token
  3. Change the API token
  4. Upload a license
  5. View the license details
  6. Update the virtual appliance
  7. View the status of a software update
  8. View the software update log
  9. Update the network and application settings
  10. View the network and application settings
  11. Retrieve compressed log files

### 1. Authentication

Each API request requires a valid API token. The API token must be sent on every request as a query parameter: `?token=yourtoken`, except for the initial **setup** API call.

> *You **MUST** _Set the API token_ prior to making any other API calls.*

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
POST /api/v1/admin/setup?token=yourtoken
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

### 6. Update the virtual appliance

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
    "log": "[1432140922][VIRTUAL APPLIANCE] Updating virtual appliance successful"
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
[1433080791][VIRTUAL APPLIANCE] Updating virtual appliance. Please wait..
[1433080791][VIRTUAL APPLIANCE] Updating virtual appliance successful
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

**Powered by [Jidoteki](https://jidoteki.com) - [Copyright notices](NOTICE)**
