local compareEvents = require(script.Parent.compare_events)
local Contour       = require(script.Parent.contour)

local function orderEvents(sortedEvents)
	local event, tmp
	local resultEvents = { }
	for i = 1, #sortedEvents do
		event = sortedEvents[i]
		if ((event.left and event.inResult) or (not event.left and event.otherEvent.inResult)) then
			resultEvents[#resultEvents + 1] = event
		end
	end

	local sorted = false
	while not sorted do
		local len = #resultEvents
		for i = 1, len do
			sorted = true
			if i + 1 <= len and compareEvents(resultEvents[i], resultEvents[i + 1]) == 1 then
				tmp = resultEvents[i]
				resultEvents[i] = resultEvents[i + 1]
				resultEvents[i + 1] = tmp
				sorted = false
			end
		end
	end

	for i = 1, #resultEvents do
		event = resultEvents[i]
		event.otherPos = i
	end

	for i = 1, #resultEvents do
		event = resultEvents[i]
		if not event.left then
			tmp = event.otherPos
			event.otherPos = event.otherEvent.otherPos
			event.otherEvent.otherPos = tmp
		end
	end

	return resultEvents
end

local function nextPos(pos, resultEvents, processed, origPos)
	local newPos = pos + 1
	local p = resultEvents[pos].point
	local p1
	local length = #resultEvents

	if newPos < length then
		p1 = resultEvents[newPos].point
		while newPos < length and (p1[1] == p[1]) and (p1[2] == p[2]) do
			if not processed[newPos] then
				return newPos
			else
				newPos = newPos + 1
			end
			p1 = resultEvents[newPos].point
		end
	end

	newPos = pos - 1

	while (processed[newPos] and newPos > origPos) do
		newPos = newPos - 1
	end

	return newPos
end

local function initializeContourFromContext(event, contours, contourId)
	local contour = Contour()
	if event.prevInResult ~= nil then
		local prevInResult = event.prevInResult
		local lowerContourId = prevInResult.outputContourId + 1
		local lowerResultTransition = prevInResult.resultTransition

		if lowerResultTransition > 0 then
			local lowerContour = contours[lowerContourId]

			if lowerContour.holeOf ~= nil then
				local parentContourId = lowerContour.holeOf
				contours[parentContourId].holeIds[#contours[parentContourId].holeIds + 1] = contourId
				contour.holeOf = parentContourId
				contour.depth = contours[lowerContourId].depth
			else
				contours[lowerContourId].holeIds[#contours[lowerContourId].holeIds + 1] = contourId
				contour.holeOf = lowerContourId
				contour.depth = contours[lowerContourId].depth + 1
			end
		else
			contour.holeOf = nil
			contour.depth = contours[lowerContourId].depth
		end
	else
		contour.holeOf = nil
		contour.depth = 0
	end
	return contour
end

return function (sortedEvents)
	local len
	local resultEvents = orderEvents(sortedEvents)

	local processed = { }
	local contours  = { }

	len = #resultEvents
	for i = 1, len do
		if processed[i] then
			continue
		end

		local contourId = #contours
		local contour   = initializeContourFromContext(resultEvents[i], contours, contourId)

		local markAsProcessed = (function (pos)
			processed[pos] = true
			resultEvents[pos].outputContourId = contourId
		end)

		local pos = i
		local origPos = i

		local initial = resultEvents[i].point
		contour.points[#contour.points + 1] = initial

		while true do
			markAsProcessed(pos)
			pos = resultEvents[pos].otherPos

			markAsProcessed(pos)
			contour.points[#contour.points + 1] = resultEvents[pos].point

			pos = nextPos(pos, resultEvents, processed, origPos)
			if pos == origPos then
				break
			end
		end

		contours[#contours + 1] = contour
	end

	return contours
end
