local TinyQueue = { }

local function defaultCompare(a, b)
	return a < b and -1 or (a > b and 1 or 0)
end

function TinyQueue.new(data, compare)
	local this = { }
	this.data    = data or { }
	this.compare = compare or defaultCompare
	this.length  = #this.data

	function this.push(item)
		table.insert(this.data, item)
		this.length = this.length + 1
		this._up(this.length)
	end

	function this.pop()
		if this.length == 0 then return end

		local top    = this.data[1]
		local bottom = this.data[#this.data]
		table.remove(this.data, #this.data)

		this.length = this.length - 1

		if this.length > 0 then
			this.data[1] = bottom
			this._down(1)
		end

		return top
	end

	function this.peek()
		return this.data[1]
	end

	function this._up(pos)
		local item = this.data[pos]

		while (pos > 1) do
			local parent  = bit32.rshift((pos - 1), 1) + 1
			local current = this.data[parent]
			if this.compare(item, current) >= 0 then
				break
			end
			this.data[pos] = current
			pos = parent
		end

		this.data[pos] = item
	end

	function this._down(pos)
		local halfLength = bit32.rshift(this.length, 1) + 1
		local 		item = this.data[pos]

		while (pos < halfLength) do
			local left  = bit32.lshift(pos, 1)
			local best  = this.data[left]
			local right = left + 1


			if right <= this.length and this.compare(this.data[right], best) < 0 then
				left = right
				best = this.data[right]
			end

			if this.compare(best, item) >= 0 then
				break
			end

			this.data[pos] = best
			pos = left
		end

		this.data[pos] = item
	end


    if (this.length > 0) then
		for i = bit32.rshift(this.length, 1) + 1, 1, -1 do
			this._down(i)
		end
    end

	return this
end

return TinyQueue
