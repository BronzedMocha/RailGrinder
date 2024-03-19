local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local Component = require(packages:WaitForChild("Component"))

local ComponentHandler = Knit.CreateService {
    Name = "ComponentHandler";
    Client = {};
}

function ComponentHandler:GetComponentClass(tag)
    assert(self.components[tag], "[ComponentHandler] Given tag '"..tag.."' not found in components list.")
    return self.components[tag]
end

function ComponentHandler:GetComponentFromInstance(tag, instance)
    assert(self.components[tag], "[ComponentHandler] Given tag '"..tag.."' not found in components list.")
    return self.components[tag]:FromInstance(instance)
end

function ComponentHandler:WaitForComponentFromInstance(tag, instance)
    while not self.components[tag] do
        task.wait(0.1)
    end
    return self.components[tag]:FromInstance(instance)
end

function ComponentHandler:KnitInit()
    self.components = {}
    for _, instance in pairs(ServerScriptService:WaitForChild("Server"):WaitForChild("components"):GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, error = pcall(function()
                --print("Loading component '"..instance.Name.."'")
            self.components[instance.Name] = require(instance)
            end)

        if not success then
                warn(error)
            end
        end
    end

    Knit.ComponentsLoaded = true
end


return ComponentHandler