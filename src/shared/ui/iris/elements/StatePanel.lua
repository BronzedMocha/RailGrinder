local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Iris = require(packages:WaitForChild("Iris"))

local function StatePanel()
    Iris:Connect(function()
        -- use a unique window size, rather than default
        local windowSize = Iris.State(Vector2.new(300, 400))
    
        Iris.Window({"Character State"}, {size = windowSize})
            Iris.Table()
        Iris.End()
    end)
end

return StatePanel