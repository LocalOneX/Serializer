# Serializer.luau Version: 1.0.0
Configured for ROBLOX aswell as executors
## Config Documentation

## Usage
executor:
```lua

```

roblox:
```lua
local __sr = require("./Serializer")
local serializer = __sr.new(
	{debug_functions =true,debug_typeclass = true, table_return_str = "test", disable_index = true}
)

local test = {
	hi = true,
	[1] = false,
	a1 = function(...)
		
	end,
	Vector3.new(1,1,1),
	math.huge,
	Instance.new("Part")
}

warn(serializer)
print(serializer:serialize(test))
```
