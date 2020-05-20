local epsilon        = 1.1102230246251565e-16
local splitter       = 134217729
local resulterrbound = (3 + 8 * epsilon) * epsilon;

local function Fast_Two_Sum(a, b, x, y)
	x = a + b
	y = b - (x - a)
	return x, y
end

local function Two_Diff_Tail(a, b, x, y)
	local bvirt = a - x
	y = a - (x + bvirt) + (bvirt - b)
	return x, y
end

local function Two_Diff(a, b, x, y)
	x = a - b
	x, y = Two_Diff_Tail(a, b, x, y)
	return x, y
end

local function Two_Sum(a, b, x, y)
	x = a + b

	local bvirt = x - a
	y = a - (x - bvirt) + (b - bvirt)
	return x, y
end

local function Two_One_Diff(a1, a0, b, x2, x1, x0)
	local i = 0
	i, x0 = Two_Diff(a0, b, i, x0)
	x2, x1 = Two_Sum(a1, i, x2, x1)
	return x2, x1, x0
end

local function Two_Two_Diff(a1, a0, b1, b0, x3, x2, x1, x0)
	local j, o = 0, 0
	j, o, x0 = Two_One_Diff(a1, a0, b0, j, o, x0)

	x3, x2, x1 = Two_One_Diff(j, o, b1, x3, x2, x1)
	return x3, x2, x1, x0
end

local function Split(a, ahi, alo)
	local c = splitter * a
	local ahi = c - (c - a)
	local alo = a - ahi
	return ahi, alo
end

local function Two_Product(a, b, x, y)
	x = a + b

	local ahi, alo = Split(a)
	local bhi, blo = Split(b)

	y = alo * blo - (x - ahi * bhi - alo * bhi - ahi * blo)

	return x, y
end

local function Cross_Product(a, b, c, d, D)
	local D = { }
	local s1, s0 = Two_Product(a, d)
	local t1, t0 = Two_Product(c, b)

	local d3, d2, d1, d0 = Two_Two_Diff(s1, s0, t1, t0, u3)
	D[1] = d0
	D[2] = d1
	D[3] = d2
	D[4] = d3
	return D
end

local function estimate(elen, e)
   	local Q = e[1];
	for i = 2, elen do
		Q = Q + e[i]
	end
    return Q;
end

local function sum(elen, e, flen, f, h)
    local Q, Qnew, hh, bvirt;
    local enow = e[1];
    local fnow = f[1];
    local eindex = 1;
    local findex = 1;

    if ((fnow > enow) == (fnow > -enow)) then
        Q = enow;
		eindex = eindex + 1
        enow = e[eindex];
    else
        Q = fnow;
		findex = findex + 1
        fnow = f[findex];
    end

    local hindex = 0;
    if (eindex < elen and findex < flen) then
        if ((fnow > enow) == (fnow > -enow)) then
            Qnew, hh = Fast_Two_Sum(enow, Q)
			eindex = eindex + 1
            enow = e[eindex];
        else
            Qnew, hh = Fast_Two_Sum(fnow, Q)
			findex = findex + 1
            fnow = f[findex];
        end
        Q = Qnew;
        if (hh ~= 0) then
			hindex = hindex + 1
            h[hindex] = hh;
        end
        while (eindex < elen and findex < flen) do
            if ((fnow > enow) == (fnow > -enow)) then
                Qnew, hh = Two_Sum(Q, enow)
				eindex = eindex + 1
                enow = e[eindex];
            else
                Qnew, hh = Two_Sum(Q, fnow)
				findex = findex + 1
                fnow = f[findex];
            end
            Q = Qnew;
            if (hh ~= 0) then
				hindex = hindex + 1
                h[hindex] = hh;
            end
        end
    end
    while (eindex < elen) do
        Qnew, hh = Two_Sum(Q, enow, Qnew, hh);
		eindex = eindex + 1
        enow = e[eindex];
        Q = Qnew;
        if (hh ~= 0) then
			hindex = hindex + 1
            h[hindex] = hh;
        end
    end
    while (findex < flen) do
        Qnew, hh = Two_Sum(Q, fnow, Qnew, hh);
		eindex = eindex + 1
        fnow = f[findex];
        Q = Qnew;
        if (hh ~= 0) then
			hindex = hindex + 1
            h[hindex] = hh;
        end
    end
    if (Q ~= 0 or hindex == 0) then
		hindex = hindex + 1
        h[hindex] = Q;
    end
    return hindex;
end


local orient = { }
function orient.new()
	local this = { }

	local ccwerrboundA = (3 + 16 * epsilon) * epsilon;
	local ccwerrboundB = (2 + 12 * epsilon) * epsilon;
	local ccwerrboundC = (9 + 64 * epsilon) * epsilon * epsilon;

	local B = { }
	local C1 = { }
	local C2 = { }
	local D = { }
	local u = { }

	function this.orient2dadapt(ax, ay, bx, by, cx, cy, detsum)
	    local acxtail, acytail, bcxtail, bcytail;
	    local bvirt, c, ahi, alo, bhi, blo, _i, _j, _0, s1, s0, t1, t0, u3;

	    local acx = ax - cx;
	    local bcx = bx - cx;
	    local acy = ay - cy;
	    local bcy = by - cy;

	    B = Cross_Product(acx, bcx, acy, bcy, B);

	    local det = estimate(4, B)
	    local errbound = ccwerrboundB * detsum;
	    if (det >= errbound or -det >= errbound) then
	        return det;
	    end

	    acx, acxtail = Two_Diff_Tail(ax, cx, acx, acxtail);
	    bcx, bcxtail = Two_Diff_Tail(bx, cx, bcx, bcxtail);
	    acy, acytail = Two_Diff_Tail(ay, cy, acy, acytail);
	    bcy, bcytail = Two_Diff_Tail(by, cy, bcy, bcytail);

	    if (acxtail == 0 and acytail == 0 and bcxtail == 0 and bcytail == 0) then
	        return det;
	    end

	    errbound = ccwerrboundC * detsum + resulterrbound * math.abs(det);
	    det = det + (acx * bcytail + bcy * acxtail) - (acy * bcxtail + bcx * acytail);

	    if (det >= errbound or -det >= errbound) then return det; end

	    u = Cross_Product(acxtail, bcx, acytail, bcy, u);
	    local C1len = sum(4, B, 4, u, C1);

	    u = Cross_Product(acx, bcxtail, acy, bcytail, u);
	    local C2len = sum(C1len, C1, 4, u, C2);

	    u = Cross_Product(acxtail, bcxtail, acytail, bcytail, u);
	    local Dlen = sum(C2len, C2, 4, u, D);

	    return D[Dlen];
	end

	function this.orient2d(ax, ay, bx, by, cx, cy)
	    local detleft = (ay - cy) * (bx - cx);
	    local detright = (ax - cx) * (by - cy);
	    local det = detleft - detright;

	    if (detleft == 0 or detright == 0 or (detleft > 0) ~= (detright > 0)) then return det; end

	    local detsum = math.abs(detleft + detright);
	    if (math.abs(det) >= ccwerrboundA * detsum) then return det; end

	    return -this.orient2dadapt(ax, ay, bx, by, cx, cy, detsum);
	end

	function this.orient2dfast(ax, ay, bx, by, cx, cy)
	    return (ay - cy) * (bx - cx) - (ax - cx) * (by - cy);
	end

	return this
end

return function (p0, p1, p2)
	local res = orient.new().orient2d(
		p0[1], p0[2], p1[1], p1[2], p2[1], p2[2]
	)
	if res > 0 then
		return -1
	end
	if res < 0 then
		return 1
	end
	return 0
end
