local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.upstream-jwt.access"
local kong = kong
local find = string.find

-- Extend Base Plugin and instantiate with a name of "kong-upstream-jwt"
-- Ref: https://docs.konghq.com/latest/plugin-development/custom-logic/#handlerlua-specifications
local KongUpstreamJWTHandler = BasePlugin:extend()
function KongUpstreamJWTHandler:new()
  KongUpstreamJWTHandler.super.new(self, "upstream-jwt")
end

function KongUpstreamJWTHandler:access(conf)
  KongUpstreamJWTHandler.super.access(self)

  -- If request path matches one of the routes, a new empty JWT will be provisioned
  -- Else, an existing JWT tied to the access token will be loaded
  local path = kong.request.get_path()
  local prelogin = find(path, "/v1/prelogin/grant", nil, true)

  if prelogin then
    access.execute(conf)
  else
    access.add_existing_jwt(conf)
  end

end

KongUpstreamJWTHandler.PRIORITY = 899 -- This plugin needs to run after auth plugins so it has access to `ngx.ctx.authenticated_consumer`, and needs to run after rate limiting
KongUpstreamJWTHandler.VERSION = "1.2"

return KongUpstreamJWTHandler
