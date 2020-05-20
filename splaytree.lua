local Node = require(script.node)
local loadRecursive, createList, toList, sortedListToBST, mergeLists, sort

function loadRecursive(this, keys, values, start, End)
    local size = End - start
    if size > 0 then
        local middle = start + math.floor(size / 2)
        local key = keys[middle + 1]
        local data = values[middle + 1]
        local node = Node(key, data)
        node.left = loadRecursive(this, keys, values, start, middle)
        node.right = loadRecursive(this, keys, values, middle + 1, End)
        return node
    end
    return nil
end

function createList(this, keys, values)
    local head = Node(nil, nil)
    local p = head
    do
        local i = 0
        while i < #keys do
            p = (function(o, i, v)
                o[i] = v
                return v
            end)(
                p,
                "next",
                Node(keys[i + 1], values[i + 1])
            )
            i = i + 1
        end
    end
    p.next = nil
    return head.next
end

function toList(this, root)
    local current = root
    local Q = {}
    local done = false
    local head = Node(nil, nil)
    local p = head
    while not done do
        if current then
			Q[#Q + 1] = current
            current = current.left
        else
            if #Q > 0 then
                current = (function()
                    p = (function(o, i, v)
                        o[i] = v
                        return v
                    end)(
                        p,
                        "next",
                        table.remove(Q)
                    )
                    return p
                end)()
                current = current.right
            else
                done = true
            end
        end
    end
    p.next = nil
    return head.next
end

function sortedListToBST(this, list, start, End)
    local size = End - start
    if size > 0 then
        local middle = start + math.floor(size / 2)
        local left = sortedListToBST(this, list, start, middle)
        local root = list.head
        root.left = left
        list.head = list.head.next
        root.right = sortedListToBST(this, list, middle + 1, End)
        return root
    end
    return nil
end

function mergeLists(this, l1, l2, compare)
    local head = Node(nil, nil)
    local p = head
    local p1 = l1
    local p2 = l2
    while (p1 ~= nil) and (p2 ~= nil) do
        if compare(p1.key, p2.key) < 0 then
            p.next = p1
            p1 = p1.next
        else
            p.next = p2
            p2 = p2.next
        end
        p = p.next
    end
    if p1 ~= nil then
        p.next = p1
    elseif p2 ~= nil then
        p.next = p2
    end
    return head.next
end

function sort(this, keys, values, left, right, compare)
    if left >= right then
        return
    end
    local pivot = keys[bit32.arshift(left + right, 1) + 1]
    local i = left - 1
    local j = right + 1
    while true do
        repeat
            do
                i = i + 1
            end
        until not (compare(keys[i + 1], pivot) < 0)
        repeat
            do
                j = j - 1
            end
        until not (compare(keys[j + 1], pivot) > 0)
        if i >= j then
            break
        end
        local tmp = keys[i + 1]
        keys[i + 1] = keys[j + 1]
        keys[j + 1] = tmp
        tmp = values[i + 1]
        values[i + 1] = values[j + 1]
        values[j + 1] = tmp
    end
    sort(this, keys, values, left, j, compare)
    sort(this, keys, values, j + 1, right, compare)
end

local function DEFAULT_COMPARE(a, b)
    return ((a > b) and 1) or (((a < b) and -1) or 0)
end

local function splay(this, i, t, comparator)
    local N = Node(nil, nil)
    local l = N
    local r = N
	local xxxx = time()
    while true do
        local cmp = comparator(i, t.key)
        if cmp < 0 then
            if t.left == nil then
                break
            end
            if comparator(i, t.left.key) < 0 then
                local y = t.left
                t.left = y.right
                y.right = t
                t = y
                if t.left == nil then
                    break
                end
            end
            r.left = t
            r = t
            t = t.left
        elseif cmp > 0 then
            if t.right == nil then
                break
            end
            if comparator(i, t.right.key) > 0 then
                local y = t.right
                t.right = y.left
                y.left = t
                t = y
                if t.right == nil then
                    break
                end
            end
            l.right = t
            l = t
            t = t.right
        else
            break
        end
    end
    l.right = t.left
    r.left = t.right
    t.left = N.right
    t.right = N.left
    return t
end

local function insert(this, i, data, t, comparator)
    local node = Node(i, data)
    if t == nil then
        node.left = (function(o, i, v)
            o[i] = v
            return v
        end)(node, "right", nil)
        return node
    end
    t = splay(this, i, t, comparator)
    local cmp = comparator(i, t.key)
    if cmp < 0 then
        node.left = t.left
        node.right = t
        t.left = nil
    elseif cmp >= 0 then
        node.right = t.right
        node.left = t
        t.right = nil
    end
    return node
end

local function split(this, key, v, comparator)
    local left = nil
    local right = nil
    if v then
        v = splay(this, key, v, comparator)
        local cmp = comparator(v.key, key)
        if cmp == 0 then
            left = v.left
            right = v.right
        elseif cmp < 0 then
            right = v.right
            v.right = nil
            left = v
        else
            left = v.left
            v.left = nil
            right = v
        end
    end
    return {left = left, right = right}
end

local function merge(this, left, right, comparator)
    if right == nil then
        return left
    end
    if left == nil then
        return right
    end
    right = splay(this, left.key, right, comparator)
    right.left = left
    return right
end



-- main

local Tree = { }

function Tree.new(comparator)
	local this = { }
	this._root = nil
	this._size = 0
	this._comparator = comparator

	function this.root()
		return this._root
	end

	function this.size()
		return this._size
	end

	function this.insert(key, data)
		this._size = this._size + 1
		this._root = insert(this, key, data, this._root, this._comparator)
		return this._root
	end

	function this.add(key, data)
		local node = Node(key, data)
		if this._root == nil then
            node.left = (function(o, i, v)
                o[i] = v
                return v
            end)(node, "right", nil)
			this._size = this._size + 1
			this._root = node
		end

		local comp = this._comparator
		local t = splay(this, key, this._root, comp)
		local cmp = comp(key, t.key)

		if cmp == 0 then
			this._root = t
		else
			if cmp < 0 then
				node.left = t.left
				node.right = t
				t.left = nil
			elseif cmp > 0 then
				node.right = t.right
				node.left = t
				t.right = nil
			end
			this._size = this._size + 1
			this._root = node
		end

		return this._root
	end

	function this.remove(key)
		this._root = this._remove(key, this._root, this._comparator)
	end

	function this._remove(i, t, comparator)
		local x
		if t == nil then
			return nil
		end
		t = splay(this, i, t, comparator)
		local cmp = comparator(i, t.key)
		if cmp == 0 then
			if t.left == nil then
				x = t.right
			else
				x = splay(this, i, t.left, comparator)
				x.right = t.right
			end
			this._size = this._size - 1
			return x
		end
		return t
	end

	function this.pop()
        local node = this._root
        if node then
            while node.left do
                node = node.left
            end
            this._root = splay(this, node.key, this._root, this._comparator)
            this._root = this._remove(node.key, this._root, this._comparator)
            return {key = node.key, data = node.data}
        end
        return nil
	end

	function this.findStatic(key)
		local current = this._root
		local comp = this._comparator
		while current do
			local cmp = comp(key, current.key)
			if cmp == 0 then
				return 0
			elseif cmp < 0 then
				current = current.left
			elseif cmp > 0 then
				current = current.right
			end
		end
		return nil
	end

	function this.find(key)
        if this._root then
            this._root = splay(this, key, this._root, this._comparator)
            if this._comparator(key, this._root.key) ~= 0 then
                return nil
            end
        end
        return this._root
	end

	function this.contains(key)
        local current = this._root
        local compare
        compare = this._comparator
        while current do
            local cmp = compare(key, current.key)
            if cmp == 0 then
                return true
            elseif cmp < 0 then
                current = current.left
            else
                current = current.right
            end
        end
        return false
	end

	function this.min()
		if this._root then
			return this.minNode(this._root).key
		end
		return nil
	end

	function this.max()
		if this._root then
			return this.maxNode(this._root).key
		end
		return nil
	end

	function this.minNode(t)
        if t == nil then
            t = this._root
        end
        if t then
            while t.left do
                t = t.left
            end
        end
        return t
    end

	function this.maxNode(t)
        if t == nil then
            t = this._root
        end
        if t then
            while t.right do
                t = t.right
            end
        end
        return t
	end

	function this.next(d)
        local root = this._root
        local successor = nil
        if d.right then
            successor = d.right
            while successor.left do
                successor = successor.left
            end
            return successor
        end
        local comparator
        comparator = this._comparator
        while root do
            local cmp = comparator(d.key, root.key)
            if cmp == 0 then
                break
            elseif cmp < 0 then
                successor = root
                root = root.left
            else
                root = root.right
            end
        end
        return successor
	end

	function this.prev(d)
        local root = this._root
        local predecessor = nil
        if d.left ~= nil then
            predecessor = d.left
            while predecessor.right do
                predecessor = predecessor.right
            end
            return predecessor
        end
        local comparator
        comparator = this._comparator
        while root do
            local cmp = comparator(d.key, root.key)
            if cmp == 0 then
                break
            elseif cmp < 0 then
                root = root.left
            else
                predecessor = root
                root = root.right
            end
        end
        return predecessor
	end

	function this.toList()
        return toList(this._root)
	end

	return this
end

return Tree
