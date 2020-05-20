local martinez = { }

martinez.operations = {
  INTERSECTION = 0,
  DIFFERENCE   = 1,
  UNION 	   = 2,
  XOR 		   = 3
}

return (function (polyA, polyB, op)
	local internal = require(script.internal)
	if type(tonumber(op)) == "number" then
		return internal(polyA, polyB, op)
	else
		return internal(polyA, polyB, martinez.operations[op:upper()])
	end
end)
