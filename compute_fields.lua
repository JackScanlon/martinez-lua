local INTERSECTION, DIFFERENCE, UNION, XOR = unpack(require(script.Parent.operation))
local NORMAL, NON_CONTRIBUTING, SAME_TRANSITION, DIFFERENT_TRANSITION = require(script.Parent.edge_type)

local function bool_xor(a,b)
	if a ~= b then
		return true
	else
		return false
	end
end

local function inResult(event, operation)
	if event.type == NORMAL then
		if operation == INTERSECTION then
			return not event.otherInOut
		elseif operation == UNION then
			return event.otherInOut
		elseif operation == DIFFERENCE then
			return (event.isSubject and event.otherInOut) or
			      (not event.isSubject and not event.otherInOut);
		elseif operation == XOR then
			return true
		end
	elseif event.type == SAME_TRANSITION then
		return operation == INTERSECTION or operation == UNION
	elseif event.type == DIFFERENT_TRANSITION then
		return operation == DIFFERENCE
	elseif event.type == NON_CONTRIBUTING then
		return false
	end
	return false
end

local function determineResultTransition(event, operation)
	local thisIn = not event.inOut;
	local thatIn = not event.otherInOut;

	local isIn;
	if operation == INTERSECTION then
		isIn = thisIn and thatIn
	elseif operation == UNION then
		isIn = thisIn or thatIn
	elseif operation == XOR then
		isIn = bool_xor(thisIn, thatIn)
	elseif operation == DIFFERENCE then
		if event.isSubject then
			isIn = thisIn and not thatIn
		else
			isIn = thatIn and not thisIn
		end
	end
	return isIn and 1 or -1
end

return function (event, prev, operation)
	if prev == nil then
		event.inOut = false
		event.otherInOut = true
	else
		if event.isSubject == prev.isSubject then
			event.inOut = not prev.inOut
			event.otherInOut = prev.otherInOut
		else
			event.inOut = not prev.otherInOut
			event.otherInOut = (prev.isVertical() and (not prev.inOut) or (prev.inOut))
		end

		if prev then
			event.prevInResult = (not inResult(prev, operation) or prev.isVertical()) and prev.prevInResult or prev
		end
	end

	local isInResult = inResult(event, operation)
	if isInResult then
		event.resultTransition = determineResultTransition(event, operation)
	else
		event.resultTransition = 0
	end
end
