local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = shared_folder:WaitForChild("types")

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local jumping = {}

local PlayerCore
local StateController

function jumping:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")

    local self = {}
    self.highest_point = nil

    self._janitor = Janitor.new()

    return setmetatable(self, {__index = jumping})
end

function jumping:update(dt)

    if not self.highest_point or PlayerCore.root.Position.Y > self.highest_point then
        self.highest_point = PlayerCore.root.Position.Y
    else
        StateController:ChangeState("freefall")
    end

    --[[if PlayerCore.root.Position.Y < self.start_y then
        StateController:ChangeState("freefall")
    end]]
end

function jumping:on_start(force_jump: boolean?)

    if force_jump then
        PlayerCore.humanoid.Jump = true
    end

    self.start_y = PlayerCore.root.Position.Y
end

function jumping:on_end()
    self.start_y = nil
    self.highest_point = nil
end

function jumping:destroy()

end

return jumping