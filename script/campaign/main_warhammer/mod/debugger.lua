function debugger_enable()
	--Vanish's PCaller
	--All credits to vanish
	--v function(func: function) --> any
	function safeCall(func)
		--out("safeCall start");
		local status, result = pcall(func)
		if not status then
			out(tostring(result), "ERROR CHECKER")
			out(debug.traceback(), "ERROR CHECKER");
		end
		--out("safeCall end");
		return result;
	end
	
	--local oldTriggerEvent = core.trigger_event;
	
	--v [NO_CHECK] function(...: any)
	function pack2(...) return {n=select('#', ...), ...} end
	--v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
	function unpack2(t) return unpack(t, 1, t.n) end
	
	--v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
	function wrapFunction(f, argProcessor)
		return function(...)
			--out("start wrap ");
			local someArguments = pack2(...);
			if argProcessor then
				safeCall(function() argProcessor(someArguments) end)
			end
			local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
			--for k, v in pairs(result) do
			--    out("Result: " .. tostring(k) .. " value: " .. tostring(v));
			--end
			--out("end wrap ");
			return unpack2(result);
			end
	end
	
	-- function myTriggerEvent(event, ...)
	--     local someArguments = { ... }
	--     safeCall(function() oldTriggerEvent(event, unpack( someArguments )) end);
	-- end
	
	--v [NO_CHECK] function(fileName: string)
	function tryRequire(fileName)
		local loaded_file = loadfile(fileName);
		if not loaded_file then
			out("Failed to find mod file with name " .. fileName)
		else
			out("Found mod file with name " .. fileName)
			out("Load start")
			local local_env = getfenv(1);
			setfenv(loaded_file, local_env);
			loaded_file();
			out("Load end")
		end
	end
	
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
	
	-- logAllObjectCalls(core);
	-- logAllObjectCalls(cm);
	-- logAllObjectCalls(game_interface);
	
	core.trigger_event = wrapFunction(
		core.trigger_event,
		function(ab)
			--out("trigger_event")
			--for i, v in pairs(ab) do
			--    out("i: " .. tostring(i) .. " v: " .. tostring(v))
			--end
			--out("Trigger event: " .. ab[1])
		end
	);
	
	cm.check_callbacks = wrapFunction(
		cm.check_callbacks,
		function(ab)
			--out("check_callbacks")
			--for i, v in pairs(ab) do
			--    out("i: " .. tostring(i) .. " v: " .. tostring(v))
			--end
		end
	)
	
	local currentAddListener = core.add_listener;
	--v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
	function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
		local wrappedCondition = nil;
		if is_function(conditionFunc) then
			--wrappedCondition =  wrapFunction(conditionFunc, function(arg) out("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
			wrappedCondition =  wrapFunction(conditionFunc);
		else
			wrappedCondition = conditionFunc;
		end
		currentAddListener(
			core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
			--core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) out("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
		)
	end
	core.add_listener = myAddListener;
end

debugger_enable()