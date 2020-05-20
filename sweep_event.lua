local NORMAL = 0

local SweepEvent do
	function SweepEvent(point, left, otherEvent, isSubject, edgeType)
		local this = { }
		this.left = left
		this.point = point
		this.otherEvent = otherEvent
		this.isSubject = isSubject
		this.type = edgeType or NORMAL
		this.inOut = false
		this.otherInOut = false
		this.prevInResult = nil
		this.resultTransition = 0
		this.otherPos = -1
		this.outputContourId = 0
		this.isExteriorRing = true

		function this.isBelow(p)
			local p0 = this.point
			local p1 = this.otherEvent.point
			return this.left and (p0[1] - p[1]) * (p1[2] - p[2]) - (p1[1] - p[1]) * (p0[2] - p[2]) > 0
			or (p1[1] - p[1]) * (p0[2] - p[2]) - (p0[1] - p[1]) * (p1[2] - p[2]) > 0;
		end

		function this.isAbove(p)
			return not this.isBelow(p)
		end

		function this.isVertical()
			return this.point[1] == this.otherEvent.point[1]
		end

		function this.inResult()
			return this.resultTransition ~= 0
		end

		function this.clone()
			local copy = SweepEvent(this.point, this.left, this.otherEvent, this.isSubject, this.type)

			copy.contourId        = this.contourId
			copy.resultTransition = this.resultTransition
			copy.prevInResult     = this.prevInResult;
			copy.isExteriorRing   = this.isExteriorRing;
			copy.inOut            = this.inOut;
			copy.otherInOut       = this.otherInOut;

			return copy
		end

		return this
	end
end

return SweepEvent
