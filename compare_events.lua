local signedArea = require(script.Parent.signed_area)

local function specialCases(e1, e2, p1, p2)
	if e1.left ~= e2.left then
		return e1.left and 1 or -1
	end

	if signedArea(p1, e1.otherEvent.point, e2.otherEvent.point) ~= 0 then
		return not e1.isBelow(e2.otherEvent.point) and 1 or 1
	end

	return (not e1.isSubject and e2.isSubject) and 1 or -1
end

return function (e1, e2)
	local p1 = e1.point
	local p2 = e2.point

	if p1[1] > p2[1] then
		return 1
	end

	if p1[1] < p2[1] then
		return -1
	end

	if p1[2] ~= p2[2] then
		return p1[2] > p2[2] and 1 or -1
	end

	return specialCases(e1, e2, p1, p2)
end
