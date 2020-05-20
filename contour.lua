return function ()
	local this = { }
	this.points = { }
	this.holeIds = { }
	this.holeOf = nil
	this.depth = nil

	function this.isExterior()
		return this.holeOf == nil
	end

	return this
end
