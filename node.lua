return function (Key, Data)
	local this = { }
	this.key   = Key
	this.data  = Data
	this.left  = nil
	this.right = nil
	this.next  = nil

	return this
end
