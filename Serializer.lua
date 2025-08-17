--!strict 
--@localonex
--[[
	
	Lightweight and optimized serializer for roblox luau, this will
	turn most luau type inputs into a copyable string output.
	TODO: Implement a lot more classes, and implement options.

]]
 
local module = {}
 
-- Internal

-- Utils 
local function _isArray(tbl: {any})
	local idx = 0
	for i, v in tbl do
		if not tonumber(i) then 
			return false
		end
		idx = idx + 1
		if idx ~= i then
			return false
		end
	end
	return true
end 
local function _indent(rep: number?)
	local rep = rep or 1
	return string.rep("	", rep)
end
local function _lazyAssert(class: string)
	assert(typeof(class) == "string", "invalid argument #1")
	return function<T>(input: T): T
		assert(typeof(input) == class, `${class}`)
		return input
	end
end
local function _toFullPath(instance: Instance)
	_lazyAssert("Instance")(instance)
end

-- Reference 
local SERIALIZE_CLASS_CASES = {
	["number"] = function(num: number)
		local num = tonumber(num)
		--assert(num == num, "$NaN") 
		local num = _lazyAssert("number")(num) :: string|number
		
		-- special number cases
		if num == math.huge then
			num = "math.huge"
		elseif num == -math.huge then
			num = "-math.huge"
		elseif num == math.pi then
			num = "math.pi"
		elseif num == -math.pi then
			num = "-math.pi"
		elseif tostring(num) == "nan" then
			num = "0/0"
		end
		return tostring(num)
	end,
	["boolean"] = function(bool: boolean) return tostring(bool) end, 
	["string"] = function(str: string) return string.format("%q", tostring(str)) end,
	["nil"] = function(input: nil) return "nil" end,
	["function"] = function(input: (...any) -> (...any), rep: number?) return `function(...: any): (...any)\n{_indent((rep or 0) + 1)}return;\n{_indent(rep)}end` end,
	
	["CFrame"] = function(input: CFrame) return `CFrame.new({table.concat({input:GetComponents()}, ", ")})` end,
	["Vector3"] = function(input: Vector3) return `Vector3.new({input.X}, {input.Y}, {input.Z})` end,
	["Vector2"] = function(input: Vector2) return `Vector2.new({input.X}, {input.Y})` end,
	["UDim2"] = function(input: UDim2) return `Vector2.new({input.X}, {input.Y})` end,
	["UDim"] = function(input: UDim) return `Udim.new({input.Scale}, {input.Offset})` end, 

	["Color3"] = function(input: Color3) return `Color3.fromRGB({input.R}, {input.G}, {input.B})` end,

	["table"] = function(tbl: {[any]: any}, rep: number?, cache: {[any]: any}?) 
		_lazyAssert("table")(tbl)
		
		-- prevent errors for cyclic tables
		local cache = cache or {}
		if cache[tbl] then
			return "{} --[[cycle]]"
		end
		cache[tbl] = true
		 
		local rep = (rep or 0) + 1  
		local output = {"{"} 
		local isArray = _isArray(tbl) 
		local idx = 0
		for key, val in tbl do
			idx += 1 
			-- build the key string
			local keyStr = ""
			if not isArray then
				keyStr = `[{Serialize(key, rep, cache)}] = `
			end 
			table.insert(output, `{_indent(rep)}{keyStr}{Serialize(val, rep, cache)};`) 
		end
		 
		table.insert(output, `{_indent(rep - 1)}}`)
		return table.concat(output, "\n")
	end,
} 

function Serialize(input: any, ...: any)
	assert(SERIALIZE_CLASS_CASES[typeof(input)], `${input}`)
	return SERIALIZE_CLASS_CASES[typeof(input)](input, ...)
end     

-- External 
 
return {
	Serialize = Serialize,
}
