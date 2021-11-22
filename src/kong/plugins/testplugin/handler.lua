local launchDarklyService = require 'datasite.launch_darkly_service'
local ldSDK = require("launchdarkly_server_sdk")
local FEATURE_FLAG = "<FEAUTURE_FLAG>"

local kong = kong

local CustomHandler = {
    VERSION  = "1.0.0",
    PRIORITY = 10
}

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end


function CustomHandler:access(config)
    -- Implement logic for the rewrite phase here (http)
    kong.log.notice("access was called")

    local booleanFlag = launchDarklyService:boolVariationDetail(ldSDK.makeUser({ key = "abcd" }), FEATURE_FLAG, false)

    kong.log.notice(dump(booleanFlag))

    if booleanFlag["value"] then
        kong.log.notice("flag was true")
    else
        kong.log.notice("flag was false")
    end
end

-- return the created table, so that Kong can execute it
return CustomHandler
