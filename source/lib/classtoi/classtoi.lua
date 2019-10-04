--- Reuh's class library version 0.1.4. Lua 5.1-5.3 and LuaJit compatible.
-- Objects and classes behavior are identical, so you can consider this to be somewhat prototype-based.
-- Features:
-- * Multiple inheritance with class(parents...) or someclass(newstuff...)
-- * Every metamethods supported
-- * Everything in a class can be redefined (and will be usable in an object) (except __super)
-- * Preserve parents metamethods if already set
-- * Instanciate with class:new(...)
-- * Test inheritance relations with class/object.is(thing, isThis)
-- * Call object:new(...) on instanciation
-- * If object:new(...) returns non-nil values, they will be returned instead of the instance
-- * Call class.__inherit(class, inheritingClass) when creating a class inheriting the previous class. If class.__inherit returns a value, it will
--   be used as the parent table instead of class, allowing some pretty fancy behavior (it's like an inheritance metamethod).
-- * Implements Class Commons
-- * I don't like to do this, but you can redefine every field and metamethod after class creation (except __index and __super).
-- Not features / Things you may want to know:
-- * Will set the metatable of all parent classes/tables if no metatable is set (the table will be its own metatable).
-- * You can't redefine __super (any __super you define will be only avaible by searching in the default __super contents).
-- * Redefining __super or __index after class creation will break everything (though it should be ok with new, is, __call and everything else).
-- * When creating a new class, the methods new, is, __call, __index and __super will always be redefined, so trying to get theses fields
--   will return the default method and not the one you've defined. However, theses defaults will be replaced by yours automatically on instanciation,
--   except __super and __index, but __index should call your __index and act like you expect. __super will however always be the default one
--   and doesn't proxy in any way yours.
-- * __index metamethods will be called with an extra third argument, which is the current class being searched in the inheritance tree.
--   You can safely ignore it.
--
-- Please also note that the last universal ancestor of the classes (defined here in BaseClass) sets the default __tostring method
-- and __name attribute for nice class-name-printing. Unlike the previoulsy described attributes and methods however, it is done in a normal
-- inheritance-way and can be rewritten without any problem (rewritting __name is especially useful to easily identify your classes).

-- Lua versions compatibility
local unpack = table.unpack or unpack

--- All Lua 5.3 metamethods.
local metamethods = {
	"__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm", "__idiv",
	"__band", "__bor", "__bxor", "__bnot", "__shl", "__shr", "__tostring",
	"__concat", "__len", "__eq", "__lt", "__le", "__index", "__newindex", "__call", "__gc"
}

local different --- When set, every class __index method will only return a value different from this one.
--- When using a proxied method, contains the last indexed class.
-- This is used for class.is(object); lastIndex will contain class so the is method can react accordingly, without having to be
-- re-set for each class (and therefore doesn't break the "different" mecanism).
local lastIndexed
local makeclass, methods, BaseClass

--- Classes defaults methods: will be re-set on each class creation.
-- If you overwrite them, you will only be able to call them from an object.
-- Methods starting with a "!" are "proxied methods": they're not present in the class table and will only be called through __index,
-- allowing more control over it (for example having access to lastIndexed).
methods = {
	--- Create an object from the class.
	-- In pratise, this only subclass the class and call the new method on it, so technically an object is a class.
	-- Objects are exaclty like classes, but the __call metamethod will be replaced by one found in the parents,
	-- or nil if doesn't exist (so an object is not directly subclassable).
	-- (If no __call method is defined in a parent, you won't be able to call the object, but obj.__call will still
	-- returns the default (subclassing) method, from one of the parents classes.)
	-- The same happens with :new and :is, but since they're not metamethods, if not defined in a parent you won't
	-- notice any difference.
	-- TL;DR (since I think I'm not really clear): you can redefine __call, :new and :is in parents and use them in objects only.
	-- A new object will only be created if calling the method "class:new(...)", if you call for example "class.new(someTable, ...)", it
	-- will only execute the constructor defined in the class on someTable. This can be used to execute the parent constructor in a child
	-- object, for example.
	-- It should also be noted that if the new method returns non-nil value(s), they will be returned instead of the object.
	["!new"] = function(self, ...)
		if lastIndexed == self then
			local obj, ret = self(), nil
			-- Setting class methods to the ones found in parents (we use rawset in order to avoid calling the __newindex metamethod)
			different = methods["!new"]  rawset(obj, "new", obj:__index("new") or nil)
			different = methods["!is"]   rawset(obj, "is", obj:__index("is") or nil)
			different = methods.__call   rawset(obj, "__call", obj:__index("__call") or nil)
			different = nil
			-- Call constructor
			if obj.new ~= methods["!new"] and type(obj.new) == "function" then ret = { obj:new(...) } end
			if not ret or #ret == 0 then
				return obj
			else
				return unpack(ret)
			end
		else
			different = methods["!new"]
			local new = lastIndexed:__index("new") or nil
			different = nil
			return new(self, ...)
		end
	end,
	--- Returns true if self is other or a subclass of other.
	-- If other is nil, will return true if self is a subclass of the class who called this method.
	-- Examples:
	-- class.is(a) will return true if a is any class or object
	-- (class()):is(class) will return true ((class()) is a subclass of class)
	-- (class()).is(class) will return false (class isn't a subclass of (class()))
	["!is"] = function(self, other)
		if type(self) ~= "table" then return false end
		if other == nil then other = lastIndexed end
		if self == other then return true end
		for _, t in ipairs(self.__super) do
			if t == other then return true end
			if t.is == methods["!is"] and t:is(other) then return true end
		end
		return false
	end,
	--- Subclass the class: will create a class inheriting self and ... (... will have priority over self).
	__call = function(self, ...)
		local t = {...}
		table.insert(t, self)
		return makeclass(unpack(t))
	end,
	--- Internal value getting; this follows a precise search order.
	-- For example: class(Base1, Base2){stuff}
	-- When getting a value from the class, it will be first searched in stuff, then in Base1, then in all Base1 parents,
	-- then in Base2, then in Base2 parents.
	-- A way to describe this will be search in the latest added tables (from the farthest child to the first parents), from left-to-right.
	-- self always refer to the initial table the metamethod was called on, super refers to the class currently being searched for a value.
	__index = function(self, k, super)
		local proxied = methods["!"..tostring(k)]
		if proxied ~= nil and proxied ~= different then -- proxied methods
			lastIndexed = self
			return proxied
		end
		for _, t in ipairs((super or self).__super) do -- search in super (will follow __index metamethods)
			local val = rawget(t, k)
			if val ~= nil and val ~= different then
				if different == nil then self[k] = val end
				return val
			end
			-- Also covers the case when different search is enabled and the raw t[k] returns an identical value, so the __index metamethod search will be tried for another value.
			if getmetatable(t) and getmetatable(t).__index then
				val = getmetatable(t).__index(self, k, t)
				if val ~= nil and val ~= different then return val end
			end
		end
	end
}

--- Create a new class width parents ... (left-to-right priority).
function makeclass(...)
	local class = {
		__super = {} -- parent classes/tables list
	}
	for k, v in pairs(methods) do -- copy class methods
		if k:sub(1, 1) ~= "!" then class[k] = v end -- except proxied methods
	end
	setmetatable(class, class)
	for _, t in ipairs({...}) do -- fill super
		if getmetatable(t) == nil then setmetatable(t, t) end -- auto-metatable the table
		if type(t.__inherit) == "function" then t = t:__inherit(class) or t end -- call __inherit callback
		table.insert(class.__super, t)
	end
	-- Metamethods query are always raw and thefore don't follow our __index, so we need to manually define thoses.
	for _, metamethod in ipairs(metamethods) do
		local inSuper = class:__index(metamethod)
		if inSuper and rawget(class, metamethod) == nil then
			rawset(class, metamethod, inSuper)
		end
	end
	return class
end

--- The class which will be a parents for all the other classes.
-- We add some pretty-printing default in here. We temporarly remove the metatable in order to avoid a stack overflow.
BaseClass = makeclass {
	__name = "class",
	__tostring = function(self)
		local mt, name = getmetatable(self), self.__name
		setmetatable(self, nil)
		local str = ("%s (%s)"):format(tostring(name), tostring(self))
		setmetatable(self, mt)
		return str
	end
}

--- Class Commons implementation.
-- https://github.com/bartbes/Class-Commons
if common_class and not common then
	common = {}
	-- class = common.class(name, table, parents...)
	function common.class(name, table, ...)
		return BaseClass(table, ...){ __name = name, new = table.init }
	end
	-- instance = common.instance(class, ...)
	function common.instance(class, ...)
		return class:new(...)
	end
end

return BaseClass
