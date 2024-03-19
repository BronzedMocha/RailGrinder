local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local landing = {}

local PlayerCore
local StateController

function landing:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    StateController = Knit.GetController("StateController")
    local self = {}


    self._janitor = Janitor.new()

    return setmetatable(self, {__index = landing})
end

function landing:update(dt)
    if os.clock() - self.start_time >= 0.5 then
        StateController:ChangeState("idle")
    end
end

function landing:on_start(transfer_data)
    self.start_time = os.clock()


end

function landing:on_end()
    return self.landing_result
end

function landing:destroy()

end

return landing