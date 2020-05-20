local Tree = require(script.splaytree)
local computeFields = require(script.Parent.compute_fields)
local possibleIntersection = require(script.Parent.possible_intersection)
local compareSegments = require(script.Parent.compare_segments)

local INTERSECTION, DIFFERENCE, UNION, XOR = unpack(require(script.Parent.operation))

return function (eventQueue, subject, clipping, sbbox, cbbox, operation)
  local sweepLine = Tree.new(compareSegments);
  local sortedEvents = { };

  local rightbound = math.min(sbbox[3], cbbox[3]);

  local prev, nxt, begin;

  while (eventQueue.length ~= 0) do
    local event = eventQueue.pop()
	sortedEvents[#sortedEvents + 1] = event

    if ((operation == INTERSECTION and event.point[1] > rightbound) or
        (operation == DIFFERENCE   and event.point[1] > sbbox[3])) then
		break;
    end

    if (event.left) then
	  prev  = sweepLine.insert(event)
	  nxt   = prev
      begin = sweepLine.minNode();

      if (prev ~= begin) then
		prev = sweepLine.prev(prev);
      else
		prev = nil;
	  end

      nxt = sweepLine.next(nxt);

      local prevEvent = prev and prev.key or nil;
      local prevprevEvent;

      computeFields(event, prevEvent, operation);
      if (nxt) then
        if (possibleIntersection(event, nxt.key, eventQueue) == 2) then
          computeFields(event, prevEvent, operation);
          computeFields(event, nxt.key, operation);
        end
      end

      if (prev) then
        if (possibleIntersection(prev.key, event, eventQueue) == 2) then
          local prevprev = prev;

          if (prevprev ~= begin) then
		    prevprev = sweepLine.prev(prevprev);
          else
			prevprev = nil
		  end

          prevprevEvent = prevprev and prevprev.key or nil;
          computeFields(prevEvent, prevprevEvent, operation);
          computeFields(event,     prevEvent,     operation);
        end
      end
    else
      event = event.otherEvent;
      prev  = sweepLine.find(event);
      nxt   = prev

      if (prev and nxt) then

        if (prev ~= begin) then
		  prev = sweepLine.prev(prev);
        else
		  prev = nil
		end

        nxt = sweepLine.next(nxt);
        sweepLine.remove(event);

        if (nxt and prev) then
          possibleIntersection(prev.key, nxt.key, eventQueue);
        end
      end
    end
  end
  return sortedEvents;
end
