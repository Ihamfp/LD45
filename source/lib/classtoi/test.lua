local T = require("knife-test")

-- luacheck: ignore T
T("Given the base class", function(T)
	local class = require("classtoi")

	-- Inheritance
	T("When subclassed with an attribute", function(T)
		local Thing = class {
			attribute = "thing"
		}

		T:assert(Thing.attribute == "thing", "Then the attribute should be set on the subclass")
		T:assert(class.attribute == nil, "Then the attribute shouldn't be set on the base class'")

		T:assert(class.is(Thing), "Then the subclass should be a subclass of the base class (class.is)")
		T:assert(Thing:is(class), "Then the subclass should be a subclass of the base class (subclass:is)")

		T("When the subclass is instanced", function(T)
			local thing = Thing:new()

			T:assert(thing.attribute == "thing", "Then the attribute should be kept")

			T:assert(class.is(thing), "Then the object should be a subclass of the base class (class.is(object))")
			T:assert(thing:is(class), "Then the object should be a subclass of the base class (object:is(class))")
			T:assert(thing:is(Thing), "Then the object should be a subclass of the subclass (object:is(subclass))")
			T:assert(Thing.is(thing), "Then the object should be a subclass of the subclass (subclass.is(object))")

			T("When setting the attribute on the instance", function(T)
				thing.attribute = "not the same thing"

				T:assert(thing.attribute == "not the same thing", "Then the attribute should be set for the object")
				T:assert(Thing.attribute == "thing", "Then the attribute should be kept for the subclass")
			end)
		end)

		T("When the subclassed is subclassed with two parents", function(T)
			local OtherThing = class {
				attribute = "other thing",
				other = true
			}

			local SubThing = Thing(OtherThing)

			T:assert(SubThing.attribute == "other thing", "Then the last added parent should have priority")

			local SubOtherThing = class(Thing, OtherThing)

			T:assert(SubOtherThing.attribute == "thing", "Then the left-most class should have priority")

			T:assert(SubThing.other and SubOtherThing.other, "Then new attribute should be always inherited")

			T("When adding a method to the first subclass", function(T)
				Thing.action = function(self, arg)
					self.attribute = arg
				end

				T("When calling it on the first subclass", function(T)
					Thing:action("new thing")

					T:assert(Thing.attribute == "new thing", "Then it affect the first subclass")
					--T:assert(SubOtherThing.attribute == "new thing", "Then it affect children wich inherit the modified attribute")
					T:assert(SubThing.attribute == "other thing", "Then it doesn't affect children which doesn't inherit the modified attribute")
				end)

				T("When calling it on another subclass", function(T)
					SubOtherThing:action("new thing")

					T:assert(Thing.attribute == "thing", "Then it doesn't affect the parent subclass")
					T:assert(SubOtherThing.attribute == "new thing", "Then it affect the subclass")
					T:assert(SubThing.attribute == "other thing", "Then it doesn't affect other subclasses")
				end)
			end)
		end)
	end)

	-- Constructor
	T("When subclassed with a constructor", function(T)
		local Thing = class {
			attribute = "class",

			new = function(self, arg)
				self.attribute = arg or "object"
			end
		}

		T:assert(Thing.attribute == "class", "Then the class should not call the constructor itself")

		T("When the subclass is instanced without arguments", function(T)
			local thing = Thing:new()

			T:assert(thing.attribute == "object", "Then the constructor should have been called on the object without arguments")
			T:assert(Thing.attribute == "class", "Then the constructor should not be called on the class")
		end)

		T("When the subclass is instanced without arguments", function(T)
			local thing = Thing:new("stuff")

			T:assert(thing.attribute == "stuff", "Then the constructor should have been called on the object with arguments")
			T:assert(Thing.attribute == "class", "Then the constructor should not be called on the class")
		end)

		T("When the subclass is subclassed and instanced with another constructor", function(T)
			local SubThing = Thing {
				new = function(self)
					self.sub = true
					Thing.new(self, "a whole new thing")
				end
			}

			local subthing = SubThing:new()

			T:assert(subthing.sub, "Then the new constructor is called on the new instance")
			T:assert(not SubThing.sub, "Then the new constructor is not called on the class")

			T:assert(subthing.attribute == "a whole new thing", "Then the parent new method was correctly accessed and called on the new instance")
			T:assert(SubThing.attribute == "class", "Then the parent new method was not called on the class")
		end)
	end)
	T("When subclassed with a constructor returning non-nil values and instanced", function(T)
		local Thing = class {
			new = function(self, arg)
				return true, arg
			end
		}

		local thing, other = Thing:new("mostly useless but cool")

		T:assert(thing == true and other == "mostly useless but cool", "Then the constructor return value should be returned instead of an object")
	end)

	-- Usual metamethods
	T("When subclassed with a metamethod", function(T)
		local Thing = class {
			value = 0,
			__add = function(self, other)
				self.value = self.value + other
				return self
			end
		}

		T:assert(Thing.value == 0, "Then the attribute is set on the subclass")

		Thing = Thing + 5

		T:assert(Thing.value == 5, "Then the metamethod is correctly called on the subclass")
		T:assert(class.value == nil, "Then the metamethod doesn't affect the base class")

		T("When the subclass is instancied", function(T)
			local thing = Thing:new()
			thing = thing + 5

			T:assert(thing.value == 10, "Then the metamethod is correctly called on the instance")
			T:assert(Thing.value == 5, "Then the metamethod doesn't affect the parent class")
		end)
	end)

	-- Redefining usual special class methods
	T("When a subclass redefine one of the default class methods", function(T)
		local Thing = class {
			is = function(self)
				return "mashed potatoes"
			end,

			__call = function(self, arg)
				return "hot potatoes with "..arg
			end
		}

		--T:assert(Thing:is(class) == true, "Then defaults methods are still used on the class")
		--T:assert(Thing():is(class) == true, "Then defaults metamethods are still used on the class")

		T("When the subclass is instancied", function(T)
			--local thing = Thing:new()

			--T:assert(thing:is(class) == "mashed potatoes", "Then the redefined method is used on the instance")
			--T:assert(thing("melted raclette") == "hot potatoes with melted raclette", "Then the redefined metamethod is used on the instance")
		end)
	end)

	--[[ Redefining __index
	T("When subclassed with an __index metamethod", function(T)
		local Thing = class {
			value = "other",

			__index = function(self, key)
				if key == "attribute" then
					return "thing"
				elseif key == "another" then
					return self.value
				end
			end
		}

		T:assert(Thing.attribute == "thing", "Then the metamethod is called as expected")
		T:assert(Thing.value == "other", "Then attribute access still works as expected")
		T:assert(Thing.another == "other", "Then the metamethod seems to correctly pass a class as the first argument")

		T("When the subclass is instanced", function(T)
			local thing = Thing:new()

			T:assert(thing.attribute == "thing", "Then the metamethod is called as expected")
			T:assert(thing.value == "other", "Then attribute access still works as expected")
			T:assert(thing.another == "other", "Then the metamethod seems to correctly pass a class as the first argument")

			T("When changing a value returned by the metamethod on the instance", function(T)
				thing.value = "new thing"

				T:assert(thing.another == "new thing", "Then the metamethod was correctly called with the instance as the first argument")
			end)
		end)
	end)]]

	-- Defining __inherit
	T("When subclassed with an __inherit method", function(T)
		local Thing = class {
			attribute = "thing",
			replace = false,
			__inherit = function(self, inheritingClass)
				inheritingClass.works = true
				if self.replace then
					return { attribute = "other thing" }
				end
			end
		}

		T:assert(Thing.works == true, "Then the __inherit method was correctly called on the class creation")

		T("When subclassing the subclass", function(T)
			Thing.works = "ok"
			local SubThing = Thing()

			T:assert(SubThing.attribute == "thing", "Then the child class still inherit the subclass")
			T:assert(SubThing.works == true, "Then the __inherit method was correctly called on the inheriting class")
			T:assert(Thing.works == "ok", "Then the __inherit method was correctly called on the inherited class")
		end)

		T("When subclassing the subclass with a return value", function(T)
			Thing.replace = true
			local SubThing = Thing()

			T:assert(SubThing.attribute == "other thing", "Then the child class inherited the return value")
			T:assert(SubThing.works == true, "Then the __inherit method was correctly called on the inheriting class")
		end)
	end)
end)
