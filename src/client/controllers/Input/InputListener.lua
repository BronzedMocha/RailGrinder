local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local game_settings = require(shared_folder:WaitForChild("Settings"))
local types = require(shared_folder:WaitForChild("types"))

local InputListener = Knit.CreateController { Name = "InputListener" }
local InputStateBind

function InputListener:TrackPlayerMovement(dt)
    self.movement_vector = Vector2.new()
    --self.jump = UserInputService:IsKeyDown(Enum.KeyCode.Space] and not self.previous_keys_down[Enum.KeyCode.Space]

    -- GAMEPAD

    if #UserInputService:GetConnectedGamepads() > 0 then
        local states = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
        for _, state in pairs(states) do
            if state.KeyCode == Enum.KeyCode.Thumbstick1 then
                self.movement_vector = Vector2.new(state.Position.X, state.Position.Y)
                return
            end
        end
    end

    -- KEYBOARD

    local x = 0
    local y = 0

    if self.keys_down[Enum.KeyCode.W] or self.keys_down[Enum.KeyCode.Up] then
        y += 1
    end

    if self.keys_down[Enum.KeyCode.S] or self.keys_down[Enum.KeyCode.Down] then
        y -= 1
    end

    if self.keys_down[Enum.KeyCode.D] or self.keys_down[Enum.KeyCode.Right] then
        x -= 1
    end

    if self.keys_down[Enum.KeyCode.A] or self.keys_down[Enum.KeyCode.Left] then
        x += 1
    end

    self.movement_vector = Vector2.new(x, y)
end

function InputListener:_connectInputs()
    self.keys_down = {}
    self.key_log = {}
    self.connected_inputs = {}

    for name, control: types.Control in pairs(game_settings.controls) do
        local keys = control.keys
        
        self.connected_inputs[name] = {}
        for i = 1, #keys do
            local keycode = keys[i];
            self.keys_down[keycode] = false
            self.key_log[keycode] = 0
            self.connected_inputs[name][keycode] = {
                UserInputService.InputBegan:Connect(function(input, process)
                    
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        self.keys_down[keycode] = true
                        self.key_log[keycode] += 1
                        InputStateBind:InputRegistered(name, input.UserInputState, keycode);
                    end
                end),
                
                UserInputService.InputChanged:Connect(function(input, process)
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        InputStateBind:InputRegistered(name, input.UserInputState, keycode);
                    end
                end),
                
                UserInputService.InputEnded:Connect(function(input, process)
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        self.keys_down[keycode] = false
                        InputStateBind:InputRegistered(name, input.UserInputState, keycode);
                    end
                end)
            }
        end
    end
end

function InputListener:SetControlBinding(binding: types.ControlBinding | {types.ControlBinding})
    local function rebindControl(binding: types.ControlBinding)
        if not self.connected_inputs[binding.control_name] then return end

        for _, keycode in self.connected_inputs[binding.control_name] do
            for _, event in keycode do
                event:Disconnect()
            end
        end
            for _, keycode in pairs(binding.keys) do
            self.connected_inputs[binding.control_name][keycode] = {
                UserInputService.InputBegan:Connect(function(input, process)
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        self.keys_down[keycode] = true
                        self.key_log[keycode] += 1
                        InputStateBind:InputRegistered(binding.control_name, input.UserInputState, keycode);
                    end
                end),
                
                UserInputService.InputChanged:Connect(function(input, process)
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        InputStateBind:InputRegistered(binding.control_name, input.UserInputState, keycode);
                    end
                end),
                
                UserInputService.InputEnded:Connect(function(input, process)
                    if (input.KeyCode == keycode or input.UserInputType == keycode) and not process then -- check for 'is combo' 
                        self.keys_down[keycode] = false
                        InputStateBind:InputRegistered(binding.control_name, input.UserInputState, keycode);
                    end
                end)
            }
        end

    end
    
    if binding.control_name then -- ControlBinding type
        rebindControl(binding)
    else -- BatchContolBinding type
        for _, controlBinding in pairs(binding) do
            rebindControl(controlBinding)
        end
    end
end

function InputListener:_disconnectInputs()
    for _, action in pairs(self.connected_inputs) do
        for _, keycode in pairs(action) do
            for _, event in pairs(keycode) do
                event:Disconnect()
            end
        end
    end
end

function InputListener:KnitStart()

    -- copy a version of player controls here
    -- override default controls with player custom controls from datastore

    InputListener:_connectInputs()
end

function InputListener:KnitInit()
    InputStateBind = Knit.GetController("InputStateBind")
end


return InputListener