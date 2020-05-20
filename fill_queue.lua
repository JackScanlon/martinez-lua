local Queue 		= require(script.tinyqueue)
local SweepEvent	= require(script.Parent.sweep_event)
local compareEvents = require(script.Parent.compare_events)

local INTERSECTION, DIFFERENCE, UNION, XOR = unpack(require(script.Parent.operation))

local max, min  = math.max, math.min

local function processPolygon(contourOrHole, isSubject, depth, Q, bbox, isExteriorRing)
	local len, s1, s2, e1, e2 = #contourOrHole

	for i = 1, len - 1 do
		s1 = contourOrHole[i]
		s2 = contourOrHole[i + 1]
		e1 = SweepEvent(s1, false, nil, isSubject)
		e2 = SweepEvent(s2, false, e1,  isSubject)
		e1.otherEvent = e2

		if (s1[1] == s2[1] and s1[2] == s2[2]) then
			continue
		end

		e1.contourId = depth
		e2.contourId = depth

		if not isExteriorRing then
			e1.isExteriorRing = false
			e2.isExteriorRing = false
		end

		if compareEvents(e1, e2) > 0 then
			e2.left = true
		else
			e1.left = true
		end

		local x = s1[1]
		local y = s1[2]

		bbox[1] = min(bbox[1], x)
		bbox[2] = min(bbox[2], y)
		bbox[3] = max(bbox[3], x)
		bbox[4] = max(bbox[4], y)

		Q.push(e1)
		Q.push(e2)
	end
end


return function (subject, clipping, sbbox, cbbox, operation)
	local eventQueue = Queue.new(nil, compareEvents)
	local polygonSet, isExteriorRing, i, ii, j, jj
	local contourId = 1

	for i = 1, #subject do
		polygonSet = subject[i]
		for j = 1, #polygonSet do
			isExteriorRing = j == 1
			if isExteriorRing then
				contourId = contourId + 1
			end
			processPolygon(polygonSet[j], true, contourId, eventQueue, sbbox, isExteriorRing)
		end
	end

	for i = 1, #clipping do
		polygonSet = clipping[i]
		for j = 1, #polygonSet do
			isExteriorRing = j == 1
			if operation == DIFFERENCE then
				isExteriorRing = false
			end
			if isExteriorRing then
				contourId = contourId + 1
			end
			processPolygon(polygonSet[j], true, contourId, eventQueue, cbbox, isExteriorRing)
		end
	end

	return eventQueue
end
