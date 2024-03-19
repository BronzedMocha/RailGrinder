local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local Component = require(packages:WaitForChild("Component"))

local ComponentHandlerClient = Knit.CreateController {
    Name = "ComponentHandlerClient";
}

function ComponentHandlerClient:GetComponentClass(tag)
    assert(self.components[tag], "[ComponentHandlerClient] Given tag '"..tag.."' not found in components list.")
    return self.components[tag]
end

function ComponentHandlerClient:GetComponentFromInstance(tag, instance)
    assert(self.components[tag], "[ComponentHandlerClient] Given tag '"..tag.."' not found in components list.")
    return self.components[tag]:FromInstance(instance)
end

function ComponentHandlerClient:KnitInit()
    self.player = game.Players.LocalPlayer
    self.components = {}
    for _, instance in pairs(self.player.PlayerScripts:WaitForChild("Client"):WaitForChild("components"):GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, error = pcall(function()
                print("Loading component '"..instance.Name.."'")
            self.components[instance.Name] = require(instance)
            end)

        if not success then
                warn(error)
            end
        end
    end

    Knit.ComponentsLoaded = true
end


return ComponentHandlerClient