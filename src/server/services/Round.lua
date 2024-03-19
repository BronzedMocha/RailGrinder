local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local game_settings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Settings"))

local Round = Knit.CreateService {
    Name = "Round";
    Client = {};
}

-- table of functions that fire when corresponding state is reached
Round.StateInitializationFunctions = {
    --[[
        foo = function()
            return bar
        end)
    ]]
}

-- table of functions that substitute for timer based yielding based on its corresponding state
Round.StateYieldingFunctions = {
    --[[
        foo = function()
            return bar
        end)
    ]]
}

local function setPlayerCollisionGroupRecursive(character)
    if character:IsA("BasePart") then
        PhysicsService:SetPartCollisionGroup(character, "Players")
    end
    for _, child in ipairs(character:GetChildren()) do
        setPlayerCollisionGroupRecursive(child)
    end
end

local ROUND_DISABLED = true

-- replaces duration of state with any given number
local STUDIO_TIME_OVERRIDES = {
    -- foo = 15;
}

function Round:Transition(to)
	self.server_round_iteration += 1
	local current_server_round_iteration = self.server_round_iteration
	-- increment step
	if to then self.current_state_index = to else self.current_state_index += 1 end

	if self.current_state_index > #game_settings.round_data then
		self.current_state_index = 1
	end
	local current = game_settings.round_data[self.current_state_index]

	--print("INITIALIZING STATE: "..current.state)
	self.StateInitializationFunctions[current.state]()
    --print("INITIALIZATION COMPLETE")

	-- initialize data for clients
	self.round_active = (current.state == "Round")
	self.round_state.Value = self.round_active
	self.round_state:SetAttribute("State", current.state)
	self.round_state:SetAttribute("Name", current.name)
	self.round_state:SetAttribute("Info", current.info)
	self.round_state:SetAttribute("Timer", "")

	-- during round
	if not current.Duration then
		self.StateYieldingFunctions[current.State](current_server_round_iteration)
	else

		local duration = current.Duration
		if RunService:IsStudio() and STUDIO_TIME_OVERRIDES[current.State] then
			duration = STUDIO_TIME_OVERRIDES[current.State]
		end

		for i = duration, 0, -1 do
			self.round_state:SetAttribute("Timer", tostring(i))
			if current_server_round_iteration ~= self.server_round_iteration then return end
			task.wait(1)
		end
	end

	task.wait()
	if current_server_round_iteration == self.server_round_iteration then
		self:Transition()
	end
end

function Round:KnitStart()
    if not ROUND_DISABLED and game_settings.round_data then
        self:Transition()
    end
end

function Round:KnitInit()
	self.round_state = Instance.new("BoolValue")
	self.round_state.Name = "RoundState"
	self.round_state.Parent = ReplicatedStorage

	self.current_state_index = 0
	self.server_round_iteration = 0

	self.round_active = false
end

return Round