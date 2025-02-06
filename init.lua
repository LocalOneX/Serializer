--[=[
	Serialier.luau
	@LocalOnex
	
	i'm too lazy to write stuff here, everything is documented @
	https://raw.githubusercontent.com/LocalOneX/serializer/refs/heads/main/README.md
]=]--
--TODO: optimize, restructre, make more readable, add more types

local repo = "https://github.com/LocalOneX/serializer" --/blob/main/init.luau 

local module = {
	Indent = "	",
} 

export type config = {
	debug_typeclass: boolean?,
	debug_functions: boolean?, 
	disable_index: boolean?,
	disable_json: boolean?,
	disable_returntable: boolean?,
	table_return_str: string?,
	format_cframe_vector: boolean?
}

local http = game:GetService("HttpService")
local function encode(...) return http:JSONEncode(...) end
local function decode(...) return http:JSONDecode(...) end 

--https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
-- this function converts a string to base64
function to_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- this function converts base64 to string
function from_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

function indent(str: string, lvl: number?)
	lvl = lvl or 1

	return string.rep(module.Indent, lvl) .. str
end

local h = {
	"--[=[",
	indent"@LocalOnex",
	indent"@repository: "..repo, 
	indent"@decumentation: https://raw.githubusercontent.com/LocalOneX/serializer/refs/heads/main/README.md"
}
local header = table.concat(h, "\n")

local function default() return "ROBLOX" end
local f = (function() return identifyexecutor or getexecutorname or whatexecutor or default end)()
local EXECUTOR_NAME = f()
warn(EXECUTOR_NAME)
local isExecutor = EXECUTOR_NAME ~= "ROBLOX"
local defaultConfig = {}

getscriptbytecode = getscriptbytecode or function() return "UNSUPPORTED" end

function module.new(config: config|nil)
	--@param config serializer configuration
	--@return self new serializer object
	
	config = config or defaultConfig
	assert(typeof(config) == "table", "[Serializer] param 'config' must be 'table|nil'!")
	
	local head = header
	
	if next(config) then
		head = head .. "\n" .. indent("config:", 1) .. "\n"
		
		local len = 0
		for i, v in next, config do
			len += 1
		end
		
		local cl = 0
		for i, v in next, config do
			cl += 1
			head = head .. indent(tostring(i) .. ": " .. tostring(v), 2)..(cl < len and "\n" or "")
		end
	end
	
	if EXECUTOR_NAME ~= "ROBLOX" then
		head = head .. indent("@executor: "..EXECUTOR_NAME)
	end
	
	head = head .. "\n]=]--\n\n"
	
	local raw = {
		config = config,
		output = head.."\n"
	} 

	local self = setmetatable(raw, {__index = module})
	 
	return self
end  

function module:write(str) 
	self.output = self.output .. str
end

function module:lookup(class,...)
	if class == "function" then
		return self:s_function(...)
	elseif class == "table" then
		return self:s_table(...)
	elseif class == "string" then
		return self:s_string(...)
	elseif class == "number" then
		return self:s_number(...)
	elseif class == "Vector3"  then
		return self:s_Vector3(...)
	elseif class == "CFrame" then
		return self:s_CFrame(...)
	elseif class == "Instance" then
		return self:s_Instance(...)
	elseif tostring(...) then
		return tostring(...)
	end
	
	return "UNSUPPORTED"
end

--- serialize types
type r = string
type f = (...any) -> (...any)
type tbl = {[any]: any}
local serializer = {}
function module:s_string(str:string)
	return tostring(str)
end

function module:s_Vector3(vector3:Vector3)
	if vector3 == Vector3.one then
		return "Vector3.one"
	elseif vector3 == Vector3.zero then
		return "Vector3.zero"
	elseif vector3 == Vector3.xAxis then
		return "Vector3.xAxis"
	elseif vector3 == Vector3.yAxis then
		return "Vector3.yAxis"
	elseif vector3 == Vector3.zAxis then
		return "Vector3.zAxis" 
	end
	
	return Vector3.new(vector3.X, vector3.Y, vector3.Z)
end

function module:s_CFrame(cframe:CFrame)
	if cframe == CFrame.identity then
		return "CFrame.identity" 
	end
	
	if self.config.format_cframe_vector then
		return "CFrame.new("..self:s_Vector3(cframe.Position)..")"
	end
	
	return string.format("CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", cframe:GetComponents())
end

function module:s_Instance(instance:Instance) 
	if instance.Parent == nil and select(1, pcall(function() Instance.new(instance.Name) end)) == true then
		return "Instance.new(\""..instance.Name.."\") --[[Possibly inaccurate]]"
	end
	
	return instance:GetFullName()
end

function module:s_number(int:number)
	if int == math.huge then
		return "math.huge"
	elseif int == -math.huge then
		return "-math.huge"
	elseif tostring(int) == "nan" then
		return "0/0" 
	end
	
	return tostring(int)
end

function module:s_function(f:f, lvl:number?):r
	--@param f function to write
	--@return serialized function str
	lvl = lvl or 1
	
	--repository that taught me about function values
	--https://github.com/zyzxti123/Serializer/blob/main/source.lua 
	
	local args = {}
	if isExecutor then
		local info = debug.getinfo(f)

		if info.nups then
			for i = 1, info.nups do
				table.insert(args, "p"..i)
			end
		end

		if info.is_varang then
			table.insert(args, "...")
		end 
	end
	
	local strArgs = #args == 1 and "" or table.concat(args, ", ")
	local getupvalues = debug.getupvalues
	
	local str = "function("..strArgs..")\n" 
	if self.config.debug_functions then
		if not isExecutor then
			str = str .. indent("--failed to get params\n",lvl)
			str = str .. indent("--ROBLOX doesn't support 'debug.getupvalues', please use an executor.",lvl)
		elseif getupvalues then
			local upvalues = "--[=[\n"..indent("Upvalues:",lvl).."\n"
			for i, v in next, getupvalues(f) do
				upvalues = upvalues .. tostring(i) .. ": " .. tostring(v)
			end
			upvalues = upvalues .. "]=]--"
			str = str .. upvalues .. "\n"
		else
			str = str .. indent("--"..EXECUTOR_NAME.."doesn't support 'debug.getupvalues'.",lvl)
		end 
	end
	
	str = str .. "\n" .. indent("--unable to extract inner\n",lvl)..indent("end", math.max(1, lvl-1))
	return str
end

function module:s_table(tbl:tbl, lvl:number?):r
	--@param tbl table value to be serialized
	--@param lvl indent level "	"
	--@return serialized tbl str
	
	local isHead = lvl == nil
	
	lvl = lvl or 1
	
	local str = "{\n"
	local currentLvl = lvl
	  
	if not next(tbl) or tbl == {} then
		return "{}"
	end
	
	local len = 0
	for i, v in next, tbl do
		len += 1
	end
	 
	local cl = 0
	for key, val in next, tbl do
		cl+=1
		
		local function interpoltion(v) 
			if v:find(" ") or v:find("-") then
				return "[\""..v.."\"] = " 
			end 
			
			return v.." = "
		end
		
		local function number_index(v) 
			if self.config.disable_index then
				return ""
			end 
			return "["..self:s_number(v).."] = "
		end
		
		local s = indent((
			(typeof(key) == "number" and number_index(key) or interpoltion(key))),
			lvl
		)
		local class = typeof(val)
		local finishedStr = self:lookup(class, val, lvl + 1)
		
		if finishedStr ~= "UNSUPPORTED" then
			s = s .. finishedStr
		else
			s = s .. "nil --[=[Unsupported type:"..class.."]=]"
		end
		
		s = s .. (self.config.debug_typeclass and " --[[type('"..class.."')]]" or "")
		if cl < len then
			s = s .. ",\n"
		end 
		
		str = str .. s 
	end
	
	str = str .. "\n"
	local ending = "}"
	if lvl > 1 then
		ending = indent(ending, lvl-1)
	end
	
	str = str .. ending
	if not self.config.disable_returntable and isHead then
		if self.config.table_return_str then
			local st = tostring(self.config.table_return_str)
			str = "local "..st.." = "..str.."\n\nreturn "..st
		else
			str = "return "..str
		end 
	end
	
	return str
end

function module:serialize(val: any)
	--assert(typeof(method) == "string", "[Serializer] param 'method' must be 'string'!")
	
	local class = typeof(val)  
	if self.config.disable_json ~= true and class == "string" then
		if select(1, pcall(decode, val)) == true then
			class = "table"
			val = decode(val)
		end
	end
	
	local finishedStr = self:lookup(class, val)
	if finishedStr ~= "UNSUPPORTED" then
		self:write(finishedStr)
		return self.output 
	end
	 
	error("[Serializer] Unsupported type:"..tostring(val))
end

if isExecutor then
	return function (...)
		local self = module.new(...)
		
		return {
			serialize = function(...)
				return self:serialize(...)
			end,
		}
	end
end

function module:__call(...)
	return module.new(...)
end
 
table.freeze(module)
return module
