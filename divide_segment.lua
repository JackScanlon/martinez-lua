local SweepEvent    = require(script.Parent.sweep_event)
local equals        = require(script.Parent.equals)
local compareEvents = require(script.Parent.compare_events)

return function (se, p, queue)
	local r = SweepEvent(p, false, se, se.isSubject)
	local l = SweepEvent(p, true, se.otherEvent, se.isSubject)

	if equals(se.point, se.otherEvent.point) then
		print ""
	end

	r.contourId = se.contourId
	l.contourId = se.contourId

	if compareEvents(l, se.otherEvent) > 0 then
		se.otherEvent.left = true
		l.left = false
	end

	se.otherEvent.otherEvent = l
	se.otherEvent = r

	queue.push(l)
	queue.push(r)

	return queue
end
