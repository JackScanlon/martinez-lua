local divideSegment = require(script.Parent.divide_segment)
local intersection  = require(script.Parent.segment_intersection)
local equals        = require(script.Parent.equals)
local compareEvents = require(script.Parent.compare_events)

local NORMAL, NON_CONTRIBUTING, SAME_TRANSITION, DIFFERENT_TRANSITION = require(script.Parent.edge_type)


-- possibleIntersection
return function (se1, se2, queue)
	if se1.isSubject == se2.isSubject then
		return nil
	end
	local inter = intersection(
		se1.point, se1.otherEvent.point,
		se2.point, se2.otherEvent.point
	)

	local nintersections = inter and #inter or 0
	if nintersections == 0 then
		return 0
	end

	if (nintersections == 1 and
      (equals(se1.point, se2.point) or
       equals(se1.otherEvent.point, se2.otherEvent.point))) then
		return 0
	end

	if nintersections == 2 and (se1.isSubect == se2.isSubject) then
		return 0
	end

	if nintersections == 1 then
		if (not equals(se1.point, inter[1]) and not equals(se1.otherEvent.point, inter[1])) then
			divideSegment(se1, inter[1], queue)
		end
		if not equals(se2.point, inter[1]) and not equals(se2.otherEvent.point, inter[1]) then
			divideSegment(se2, inter[1], queue)
		end
		return 1
	end

	local events = { }
	local leftCoincide = false
	local rightCoincide = false

	if equals(se1.point, se2.point) then
		leftCoincide = true
	elseif compareEvents(se1, se2) == 1 then
		events[#events + 1] = se2
		events[#events + 1] = se1
	else
		events[#events + 1] = se1
		events[#events + 1] = se2
	end

	if equals(se1.otherEvent.point, se2.otherEvent.point) then
		rightCoincide = true
	elseif compareEvents(se1.otherEvent, se2.otherEvent) == 1 then
		events[#events + 1] = se2.otherEvent
		events[#events + 1] = se1.otherEvent
	else
		events[#events + 1] = se1.otherEvent
		events[#events + 1] = se2.otherEvent
	end

	if ((leftCoincide and rightCoincide) or leftCoincide) then
		se2.type = NON_CONTRIBUTING
		se1.type = (se2.inOut == sel.inOut) and SAME_TRANSITION or DIFFERENT_TRANSITION

		if leftCoincide and not rightCoincide then
			divideSegment(events[2].otherEvent, events[1].point, queue)
		end
		return 2
	end

	if rightCoincide then
		divideSegment(events[1], events[2].point, queue)
		return 3
	end

	if events[1] ~= events[4].otherEvent then
    	divideSegment(events[1], events[2].point, queue);
    	divideSegment(events[2], events[3].point, queue);
		return 3
	end

	divideSegment(events[1], events[2].point, queue);
	divideSegment(events[4].otherEvent, events[3].point, queue);

	return 3
end
