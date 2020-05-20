local signedArea    = require(script.Parent.signed_area)
local compareEvents = require(script.Parent.compare_events)
local equals        = require(script.Parent.equals)

return function (le1, le2)
	if le1 == le2 then
		return 0
	end

	if signedArea(le1.point, le1.otherEvent.point, le2.point) ~= 0 or signedArea(le1.point, le1.otherEvent.point, le2.otherEvent.point) ~= 0 then
		if equals(le1.point, le2.point) then
			return le1.isBelow(le2.otherEvent.point) and -1 or 1
		end
		if le1.point[1] == le2.point[1] then
			return le1.point[1] < le2.point[1] and -1 or 1
		end
		if compareEvents(le1, le2) == 1 then
			return le2.isAbove(le1.point) and -1 or 1
		end
		return le1.isBelow(le2.point) and -1 or 1
	end

	if le1.isSubject == le2.isSubject then
		local p1 = le1.point
		local p2 = le2.point
		if p1[1] == p2[1] and p1[2] == p2[2] then
			p1 = le1.otherEvent.point
			p2 = le2.otherEvent.point

			if p1[1] == p2[1] and p1[2] == p2[2] then
				return 0
			else
				return le1.contourId > le2.contourId and 1 or -1
			end
		end
	else
		return le1.isSubject and -1 or 1
	end

	return compareEvents(le1, le2) == 1 and 1 or -1
end
