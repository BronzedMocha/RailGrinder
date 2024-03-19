local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(packages:WaitForChild("Knit"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local game_settings = require(shared_folder:WaitForChild("Settings"))

local Datastore

local PlayerLog = Knit.CreateService {
    Name = "PlayerLog";
    Client = {
        server_loaded = Knit.CreateProperty(false)
    };
}

local function setupPhysicsControllers(character)

	local cm = Instance.new("ControllerManager")
	local gc = Instance.new("GroundController", cm)

	local ac = Instance.new("AirController", cm)
	local cc = Instance.new("ClimbController", cm)
	local sc = Instance.new("SwimController", cm)

	local humanoid = character.Humanoid
	cm.RootPart = humanoid.RootPart
	gc.GroundOffset = humanoid.HipHeight
	cm.FacingDirection = cm.RootPart.CFrame.LookVector

	local floorSensor = Instance.new("ControllerPartSensor")
	floorSensor.SensorMode = Enum.SensorMode.Floor
	floorSensor.SearchDistance = gc.GroundOffset + 0.5
	floorSensor.Name = "GroundSensor"

	local climbSensor = Instance.new("ControllerPartSensor")
	climbSensor.SensorMode = Enum.SensorMode.Ladder
	climbSensor.SearchDistance = 1.5
	climbSensor.Name = "ClimbSensor"

	local waterSensor = Instance.new("BuoyancySensor")

	cm.GroundSensor = floorSensor
	cm.ClimbSensor = climbSensor

	waterSensor.Parent = cm.RootPart
	floorSensor.Parent = cm.RootPart
	climbSensor.Parent = cm.RootPart
	cm.Parent = character

    return waterSensor, floorSensor, climbSensor, gc, ac, cc, sc, cm
end

function PlayerLog:setup_player(player)

    local function LoadCharacter()
        player:LoadCharacter()
    end

    local function onPlayerDied()
        -- on death
        task.wait(Players.RespawnTime)
        LoadCharacter()
    end

    local function onCharacterAdded(character)
        self.player_list[player].character = character
        self.player_list[player].root = character:WaitForChild("HumanoidRootPart")
        self.player_list[player].humanoid = character:WaitForChild("Humanoid")

        if game_settings.PhysicsControllersEnabled then
            self.player_list[player].humanoid.EvaluateStateMachine = false -- Disable Humanoid state machine and physics
            task.wait() -- ensure post-load Humanoid computations are complete (such as hip height)
            
            local waterSensor,
            floorSensor,
            climbSensor,
            groundController,
            airController,
            climbController,
            swimController,
            controllerManager = setupPhysicsControllers(character)
    
            self.player_list[player].waterSensor = waterSensor
            self.player_list[player].floorSensor = floorSensor
            self.player_list[player].climbSensor = climbSensor
            self.player_list[player].groundController = groundController
            self.player_list[player].airController = airController
            self.player_list[player].climbController = climbController
            self.player_list[player].swimController = swimController
            self.player_list[player].controllerManager = controllerManager
        end

        self.player_list[player].humanoid.Died:Connect(onPlayerDied)
    end

    self.player_list[player] = {}

    -- fire methods from other services

    -- connect character added event
    player.CharacterAdded:Connect(onCharacterAdded)

    -- spawn player
    LoadCharacter()

    -- set remote property
    self.Client.server_loaded:SetFor(player, true)
end

function PlayerLog:remove_player(player)
    self.player_list[player] = nil
end

-- knit

function PlayerLog:KnitStart()
    self.player_list = {}

    for _, player in pairs(Players:GetPlayers()) do
        self:setup_player(player)
    end

    Players.PlayerAdded:Connect(function(player)
        self:setup_player(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:remove_player(player)
    end)
end


function PlayerLog:KnitInit()
    
end


return PlayerLog