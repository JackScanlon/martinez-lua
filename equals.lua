return function (p1, p2)
	if p1[1] == p2[1] then
		if p1[2] == p2[2] then
			return true
		else
			return false
		end
	end
	return false
end
