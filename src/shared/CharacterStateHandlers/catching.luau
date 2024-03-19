local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))

--local PlayerCore

local catching = {}

function catching:init(core: types.CharacterCore?)
    --PlayerCore = core or Knit.GetController("PlayerCore")
    local self = {}
    self.character_core = core

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = catching})
end

function catching:update(dt)

end

function catching:on_start(transfer_data)

end

function catching:on_end()

end

function catching:destroy()

end

return catching