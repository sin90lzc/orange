--resty请求限流模块
local limit_req = require "resty.limit.req"

local _M={}

--rate_limit

--核心限流函数
--key:限流key
--count:限制的每秒请求数
function _M.limit(key,count)
	count=tonumber(count)	
	local l,e=parseLimit(count)
	ngx.log(ngx.DEBUG,"limit key:"..key..",limit count:"..l..",limit extra:"..e)
	local lim, err = limit_req.new("rate_limit", l, e)
	if not lim then
	    ngx.log(ngx.ERR,
		    "failed to instantiate a resty.limit.req object: ", err)
	    return true
	end

	local delay, err = lim:incoming(key, true)
	if not delay then
	    if err == "rejected" then
		ngx.log(ngx.ERR, "limit req: ", err)
		return true
	    end
	    ngx.log(ngx.ERR, "failed to limit req: ", err)
	    return true 
	end

	if delay >= 0.001 then
	    ngx.sleep(delay)
	end
	return false
end

--按限流值，计算出缓冲区大小(10%限流)
function parseLimit(count)
	local l=count
	local e=math.floor(count*0.1)
	return l,e
end


return _M