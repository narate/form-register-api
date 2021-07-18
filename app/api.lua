local ngx = ngx
local cjson = cjson

local error_and_exit = function(msg)
    ngx.status = 400
    ngx.say(cjson.encode({ msg = msg }))
    ngx.exit(400)
end

_ = ngx.req.get_method() == 'POST' or ngx.exit(405)

ngx.req.read_body()

local request_body = ngx.req.get_body_data() or error_and_exit('Request body not found')
local json_body = cjson.decode(request_body) or error_and_exit('Invalid JSON format')

-- @TODO: Add verify id format
local id = json_body.id or error_and_exit('id not found') -- National ID

-- @TODO: Add name prefix API!
local name = json_body.name or error_and_exit('name not found')

-- @TODO: Add verify phone number
local phone = json_body.phone or error_and_exit('phone not found')

-- Use https://earthchie.github.io/jquery.Thailand.js/ for auto complete
local address = json_body.address or error_and_exit('address not found')

-- @TODO: decode address object as json with cjson.decode()
-- local address = cjson.decode(json_body.address) or error_and_exit('address must be json object')

local args = {
    key = ngx.var.request_id,
    values = cjson.encode {
        id = id,
        name = name,
        phone = phone,
        address = address
    }
}

local res = ngx.location.capture("/_kt/set", { args = args })

if not res or res.status ~= 201 then
    ngx.status = res.status
    ngx.say(cjson.encode({
        msg = "set values failed",
        body = res.body or '',
        status = res.status
    }))
    ngx.exit(res.status)
end

ngx.status = 201
ngx.say(cjson.encode({
    status = res.status,
    body = cjson.decode(res.body) or res.body:gsub('\r\n',''),
    key = args.key }
))
ngx.exit(201)
