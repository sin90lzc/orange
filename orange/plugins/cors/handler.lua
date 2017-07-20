local ipairs = ipairs
local tonumber = tonumber
local string_find = string.find
local orange_db = require("orange.store.orange_db")
local judge_util = require("orange.utils.judge")
local extractor_util = require("orange.utils.extractor")
local handle_util = require("orange.utils.handle")
local BasePlugin = require("orange.plugins.base_handler")

local CorsHandler = BasePlugin:extend()
CorsHandler.PRIORITY = 10000

function CorsHandler:new(store)
    CorsHandler.super.new(self, "cors-plugin")
    self.store = store
end

function getRefererDomain(referers,origins)
    local rfs=referers or origins
    if not rfs then
        return "*"
    end

    if type(rfs) == "table" then
        rfs = rfs[1]
    end
    local regex = "(https?://.*?)/.*"
    local domain,err = ngx.re.match(rfs,regex)
    if not err and domain and domain[1] then
            return domain[1]
    end
    return "*"
end

function CorsHandler:cors()
    CorsHandler.super.cors(self)
    
    local ngx_var = ngx.var
    local ngx_var_uri = ngx_var.uri
    local ngx_var_host = ngx_var.http_host
    local ngx_var_scheme = ngx_var.scheme
    local ngx_var_args = ngx_var.args
    local request_method = ngx.req.get_method()
    if request_method ~= "OPTIONS" then
        return
    end
    local referers = ngx.req.get_headers()["Referer"]
    local origins = ngx.req.get_headers()["Origin"]

    ngx.header["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
    ngx.header["Access-Control-Allow-Headers"] = "Origin, No-Cache, X-Requested-With, If-Modified-Since, Pragma, Last-Modified, Cache-Control, Expires, Content-Type"
    ngx.header["Access-Control-Allow-Credentials"] = "true"
    
    local origin = getRefererDomain(referers,origins)
    ngx.header["Access-Control-Allow-Origin"] = origin
    return ngx.exit(ngx.HTTP_OK)
end

return CorsHandler
