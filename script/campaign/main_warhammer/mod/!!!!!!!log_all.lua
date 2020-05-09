--v [NO_CHECK] function(f: function(), name: string)
function logFunctionCall(f, name)
	return function(...)
		out("function called: " .. name);
		return f(...);
	end
end

--v [NO_CHECK] function(object: any)
function logAllObjectCalls(object)
	local metatable = getmetatable(object);
	for name,f in pairs(getmetatable(object)) do
		if is_function(f) then
			out("Found " .. name);
			if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
				--Skip
			else
				metatable[name] = logFunctionCall(f, name);
			end
		end
		if name == "__index" and not is_function(f) then
			for indexname,indexf in pairs(f) do
				out("Found in index " .. indexname);
				if is_function(indexf) then
					f[indexname] = logFunctionCall(indexf, indexname);
				end
			end
			out("Index end");
		end
	end
end

cm:add_first_tick_callback(function()

end)


-- Uncomment to check UIC methods
--[[core:add_listener(
	"anyclick",
	"ComponentLClickUp",
	true,
	function(context)
		out("CHECKING UIC METHODS")
		local uic = UIComponent(context.component)
		local mt = getmetatable(uic)
		for name,f in pairs(mt) do
		if is_function(f) then
			out("uic:"..tostring(name).."()")
		elseif name == "__index" and not is_function(f) then
			for in_name, in_f in pairs(f) do
				out("Found in index:")
				out("uic:"..tostring(in_name).."()")
			end
		end
		end
	end,
	false
)]]