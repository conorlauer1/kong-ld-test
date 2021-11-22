# Prerequisites 

## Tools

- Kong Deck
https://github.com/Kong/deck#installation

- Docker

- Curl or Browser

## Update LD SDK_KEY and FEATURE_FLAG

### SDK_KEY

```
edit /src/modules/launch_darkly_service.lua
Replace <SDK_KEY> on line 3
local YOUR_SDK_KEY = "<SDK_KEY>"
```

### FEATURE_FLAG

```
edit /src/kong/plugins/testplugin/handler.lua
Replace <FEATURE_FLAG> on line 3
local FEATURE_FLAG = "<FEAUTURE_FLAG>"
```

# Build Image

```
docker build -t kongtestld:latest -f Dockerfile.kongld .
```

# Initialize Docker Network and Prep DB

## Set up Docker Network

```
docker network create kong-net
```

## Prep Postgres DB

```
docker run -d --name kong-database \
  --network=kong-net \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  -e "POSTGRES_PASSWORD=kong" \
  postgres:9.6
```

## Bootstrap Postgres DB

```
docker run --rm --network=kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PG_PASSWORD=kong" \
  -e "KONG_PASSWORD=password" \
  kongtestld:latest migrations bootstrap
```

# Run Kong

## Startup Kong

```
docker run -d --name kong \
  --network=kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PG_USER=kong" \
  -e "KONG_PG_PASSWORD=kong" \
  -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 127.0.0.1:8001:8001 \
  -p 127.0.0.1:8444:8444 \
  kongtestld:latest
  ```


## Sync configuration for testing plugin in Kong

The kong.yaml file will add a service, with a route, containing a wildcard path(e.g. /*) that has the plugin enabled that should do the boolVariation check.

This service is pointing at httpbin.org which will be the upstream service Kong proxies to.

```
cd configurations
deck sync
```

# Run the test

```
curl localhost:8000/get
```
Keep hitting this endpoint to observe weird behavior of child process crashing and updates seemingly being applied when LD Flags are enabled and disabled.

The logs do not show updates to the status for the flag checks.

Restarting the Kong container will pull in the latest value from LD App, but will not reflect the change in the internal state of LD C SDK. 
