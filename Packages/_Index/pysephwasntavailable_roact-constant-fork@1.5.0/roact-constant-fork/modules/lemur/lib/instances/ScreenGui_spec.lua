local Instance = import("../Instance")
local typeof = import("../functions/typeof")
local ZIndexBehavior = import("../Enum/ZIndexBehavior")

describe("instances.ScreenGui", function()
	it("should instantiate", function()
		local instance = Instance.new("ScreenGui")

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Instance.new("ScreenGui")

		assert.equals(typeof(instance.AbsolutePosition), "Vector2")
		assert.equals(typeof(instance.AbsoluteSize), "Vector2")
		assert.equals(typeof(instance.DisplayOrder), "number")
		assert.equals(typeof(instance.AutoLocalize), "boolean")
		assert.equals(typeof(instance.IgnoreGuiInset), "boolean")
		assert.equals(typeof(instance.ZIndexBehavior), "EnumItem")
		assert.equals(instance.ZIndexBehavior.EnumType, ZIndexBehavior)
	end)
end)