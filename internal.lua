local deepcopy do
	function deepcopy(orig, copies)
	    copies = copies or {}
	    local orig_type = type(orig)
	    local copy
	    if orig_type == 'table' then
	        if copies[orig] then
	            copy = copies[orig]
	        else
	            copy = {}
	            copies[orig] = copy
	            for orig_key, orig_value in next, orig, nil do
	                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
	            end
	            setmetatable(copy, deepcopy(getmetatable(orig), copies))
	        end
	    else
	        copy = orig
	    end
	    return copy
	end
end

local function concat( a, b )
    local result = { }
    for k,v in pairs(a) do
        table.insert(result, v)
    end
    for k,v in pairs(b) do
        table.insert(result, v)
    end
    return result
end

local subdivideSegments = require(script.subdivide_segments)
local connectEdges      = require(script.connect_edges)
local fillQueue         = require(script.fill_queue)

local INTERSECTION, DIFFERENCE, UNION, XOR = unpack(require(script.operation))

local EMPTY, Infinity = { }, math.huge

local function trivialOperation(subject, clipping, operation)
	local result
	if #subject * #clipping == 0 then
		if operation == INTERSECTION then
			result = nil
		elseif operation == DIFFERENCE then
			result = subject
		elseif operation == UNION or operation == XOR then
			result = (#subject == 0) and clipping or subject
		end
	end
	return result
end

local function compareBBoxes(subject, clipping, sbbox, cbbox, operation)
	local result

	if (sbbox[1] > cbbox[3] or
	  cbbox[1] > sbbox[3] or
	  sbbox[2] > cbbox[4] or
	  cbbox[2] > sbbox[4]) then
		if (operation == INTERSECTION) then
			result = nil
		elseif (operation == DIFFERENCE) then
			result = subject
		elseif (operation == UNION or operation == XOR) then
			result = concat(deepcopy(subject), clipping)
		end
	end
	return result;
end

-- boolean
return function (subject, clipping, operation)
	if not subject then
		return clipping
	end
	if not clipping then
		return subject
	end
	if type(subject[1][1]) == "number" then
		subject = {subject}
	end
	if type(clipping[1][1]) == "number" then
		clipping = {clipping}
	end
	if type(subject[1][1][1]) == "number" then
		subject = {subject}
	end
	if type(clipping[1][1][1]) == "number" then
		clipping = {clipping}
	end

	local trivial = trivialOperation(subject, clipping, operation)
	if trivial then
		return trivial == nil and nil or trivial
	end

	local sbbox = {Infinity, Infinity, -Infinity, -Infinity}
	local cbbox = {Infinity, Infinity, -Infinity, -Infinity}

	local eventQueue = fillQueue(subject, clipping, sbbox, cbbox, operation)
	trivial = compareBBoxes(subject, clipping, sbbox, cbbox, operation)
	if trivial then
		return trivial == nil and nil or trivial
	end

	local sortedEvents = subdivideSegments(eventQueue, subject, clipping, sbbox, cbbox, operation)
	local contours = connectEdges(sortedEvents, operation)

	local polygons = { }
	for i = 1, #contours do
		local contour = contours[i]
		if contour.isExterior() then
			local rings = {contour.points}
			for j = 1, #contour.holeIds do
				local holeId = contour.holeIds[j]
				rings[#rings + 1] = contours[holeId].points
			end
			polygons[#polygons + 1] = rings
		end
	end

	return polygons
end
