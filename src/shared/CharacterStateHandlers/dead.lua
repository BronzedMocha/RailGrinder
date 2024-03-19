local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore
local StateController


local dead = {}

function dead:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local self = {}

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = dead})
end

function dead:update(dt)
    
end

function dead:on_start(transfer_data)
    
end

function dead:on_end()
    
end

function dead:destroy()
    
end

return dead