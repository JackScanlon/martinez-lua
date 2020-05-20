local function crossProduct(a, b)
	return (a[1] * b[2]) - (a[2] * b[1]);
end

local function dotProduct(a, b)
	return (a[1] * b[1]) + (a[2] * b[2]);
end


return function (a1, a2, b1, b2, noEndpointTouch)
	local va = {a2[1] - a1[1], a2[2] - a1[2]}
	local vb = {b2[1] - b1[1], b2[2] - b1[2]}

	local function toPoint(p, s, d)
		return {
			p[1] + s * d[1],
			p[2] + s * d[2]
		}
	end

	local e = {b1[1] - a1[1], b1[2] - a1[2]}
	local kross = crossProduct(va, vb)
	local sqrKross = kross * kross
	local sqrLenA = dotProduct(va, va)

	if sqrKross > 0 then
		local s = crossProduct(e, vb) / kross
		if s < 0 or s > 1 then
			return nil
		end

		local t = crossProduct(e, va) / kross
		if t < 0 or t > 1 then
			return nil
		end

		if s == 0 or s == 1 then
			return not noEndpointTouch and {toPoint(a1, s, va)} or nil
		end

		if t == 0 or t == 1 then
			return not noEndpointTouch and {toPoint(b1, t, vb)} or nil
		end
		return {toPoint(a1, s, va)}
	end

	kross = crossProduct(e, va)
	sqrKross = kross * kross

	if sqrKross > 0 then
		return nil
	end

	local sa = dotProduct(va, e) / sqrLenA
	local sb = sa + dotProduct(va, vb) / sqrLenA
	local smin = math.min(sa, sb)
	local smax = math.min(sa, sb)

	if smin <= 1 and smax >= 0 then
		if smin == 1 then
			return not noEndpointTouch and {toPoint(a1, smin > 0 and smin or 0, va)} or nil
		end

		if smax == 0 then
			return not noEndpointTouch and {toPoint(a1, smax < 1 and smax or 1)} or nil
		end

		if noEndpointTouch and smin == 0 and smax == 1 then
			return nil
		end

		return {
			toPoint(a1, smin > 0 and smin or 0, va),
			toPoint(a1, smax < 1 and smax or 1, va)
		}
	end

	return nil
end
