local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))
local Signal = require(packages:WaitForChild("Signal"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local game_settings = require(shared_folder:WaitForChild("Settings"))
local types = require(shared_folder:WaitForChild("types"))

local PlayerCore = Knit.CreateController { Name = "PlayerCore" }
local StateController

local function getMeasurementsForCharacter(character)
    local measurements = {} :: {
        ROOT_HEIGHT: number,
        ROOT_WIDTH: number,
        BODY_HEIGHT: number,
        BODY_WIDTH: number,
        BODY_DEPTH: number,
        FOOT_WIDTH: number,
        FOOT_DEPTH: number,
        LIMB_LENGTH: number,
    }
    -- setup measurements

    local humanoid = character.Humanoid
    local root = character.HumanoidRootPart

    measurements["ROOT_HEIGHT"] = humanoid.HipHeight + (root.Size.Y/2)
    measurements["ROOT_WIDTH"] = root.Size.X
    measurements["BODY_HEIGHT"] = humanoid.HipHeight + (root.Size.Y) + character:WaitForChild("Head").Size.Y
    measurements["BODY_WIDTH"] = root.Size.X * 2
    measurements["BODY_DEPTH"] = root.Size.Z
    measurements["FOOT_WIDTH"] = character:WaitForChild("RightFoot").Size.X
    measurements["FOOT_DEPTH"] = character.RightFoot.Size.Z
    measurements["LIMB_LENGTH"] = root.Size.Y
    
    return measurements
end

function PlayerCore:_setPhysicsControllerVariables()
        self.controllerManager = self.character:WaitForChild("ControllerManager")
        self.waterSensor = self.root:WaitForChild("BuoyancySensor")
        self.floorSensor = self.root:WaitForChild("GroundSensor")
        self.climbSensor = self.root:WaitForChild("ClimbSensor")
        self.airController = self.controllerManager:WaitForChild("AirController")
        self.climbController = self.controllerManager:WaitForChild("ClimbController")
        self.swimController = self.controllerManager:WaitForChild("SwimController")
        self.groundController = self.controllerManager:WaitForChild("GroundController")
end

function PlayerCore:KnitInit()
    local function onCharacterAdded(character)
        if not character then
            character = self.player.Character or self.player.CharacterAdded:Wait()
        end

        self.character = character
        self.humanoid = character:WaitForChild("Humanoid")
        self.root = character:WaitForChild("HumanoidRootPart")

        if game_settings.PhysicsControllersEnabled then
            self:_setPhysicsControllerVariables()
        end

        self.measurements = getMeasurementsForCharacter(character)

        self.character_spawned:Fire()

        self.humanoid.Died:Connect(function()
            -- on death
        end)
    end

    self.character_spawned = Signal.new()
    self.player = game.Players.LocalPlayer

    onCharacterAdded()
    self.player.CharacterAdded:Connect(onCharacterAdded)
end

function PlayerCore:BuildCoreCache()



    return {
        character = self.character,
        humanoid = self.humanoid,
        root = self.root,

        signals = {
            character_spawned = self.character_spawned
        }
    } :: types.CharacterCore
end

return PlayerCore