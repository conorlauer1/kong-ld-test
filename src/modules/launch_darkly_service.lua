local ld = require("launchdarkly_server_sdk")

local YOUR_SDK_KEY = "<SDK_KEY>"

local kong = kong

local config = {
  key = YOUR_SDK_KEY,
  stream = false
}

kong.log.notice("LOADING LD SERVER")
ld.registerLogger("TRACE", kong.log.notice)

local client = ld.clientInit(config, 1000)

return client