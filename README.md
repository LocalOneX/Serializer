# Serializer.luau Version: 1.0.0
Configured for ROBLOX aswell as executors.
TODO: Optimization, bug fixes, readability, implement more types.
## Config Documentation
`debug_typeclass`: show '--[[type('class')]] on tables, vars, etc.

`debug_functions`: grab and show upvalues for functions

`disable_index`: remove [1] from tables ex: {[1] = true} = {true}

`disable_json`: disables auto-json in serialize

`disable_returntable`: removes 'return' from tables

`table_return_str`: instead of 'return {}' it formats  local str = {} return str

`format_cframe_vector`: instead of CFrame.new(1,1,1) it does CFrame.new(Vector3.new(1,1,1))

## Usage
executor:
```lua
local __s = loadstring(game:HttpGet("https://raw.githubusercontent.com/LocalOneX/serializer/refs/heads/main/init.lua"))() 
local serializer = __s({
	debug_functions = true,
	debug_typeclass = true, 
	table_return_str = "test", 
	disable_index = true
})
 
local test = {
	hi = true,
	[1] = false,
	a1 = function(...)

	end,
	Vector3.new(1,1,1),
	math.huge,
	Instance.new("Part")
}
   
setclipboard(serializer:serialize(test))
```

roblox:
```lua
local __sr = require("./Serializer")
local serializer = __sr.new({
	debug_functions = true,
	debug_typeclass = true, 
	table_return_str = "test", 
	disable_index = true
})

local test = {
	hi = true,
	[1] = false,
	a1 = function(...)
		
	end,
	Vector3.new(1,1,1),
	math.huge,
	Instance.new("Part")
}
 
print(serializer:serialize(test))
```
