local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local state_handlers = shared_folder:WaitForChild("CharacterStateHandlers")
local macro_handlers = shared_folder:WaitForChild("Macros")
local types = require(shared_folder:WaitForChild("types"))

local Janitor = require(packages:WaitForChild("Janitor"))
local Signal = require(packages:WaitForChild("Signal"))

local StateController = Knit.CreateController { Name = "StateController" }
local PlayerCore

export type LogEntry = {
    target_state: types.CharacterState,
    activation_time: number,
}

type RuntimeEventName = types.RuntimeEventName

local RUNTIME_EVENT_NAMES = {
    "Heartbeat",
    "PreSimulation",
    "PreAnimation",
    "PostSimulation",
    "PostAnimation",
    "PreRender",
    "RenderStepped",
    "Stepped"
}

local HUMANOID_STATE_ENUMS = Enum.HumanoidStateType:GetEnumItems()
local MAX_LOG_ENTRIES = 30
local MAX_STATE_UPDATE_ENTRIES = 200

local function find(t: table, v: any, i: number?): number?
    for index, value in t do
        if i and index > i then continue end
        if value == v then
            return index
        end
    end
end

function StateController:_setHumanoidOverrides()
    local override_states = self.state_handler_modules[self.client_data.current_state].HumanoidStateConfig

    local disable_other_states = false
    local result_index = if override_states then find(override_states, true) else nil
    
    --print("FOR STATE '"..self.client_data.current_state.."' DID WE FIND A TRUE VALUE? "..if result_index then "YES" else "NO")
    
    if result_index then
        --print("WILL DISABLE OTHER STATES")
        disable_other_states = true
    end

    for _, enum in HUMANOID_STATE_ENUMS do
        if enum == Enum.HumanoidStateType.None then continue end
        if override_states and override_states[enum] then
            --print("setting state '"..enum.Name.."' to "..tostring(override_states[enum]))
            PlayerCore.humanoid:SetStateEnabled(enum, override_states[enum])
        else
            if not override_states then
                --print("no override states found")
            else
                --print("no override state of enum '"..tostring(enum.Name).."' found")
            end
            --print("overriding state '"..enum.Name.."' to "..tostring(not disable_other_states))
            PlayerCore.humanoid:SetStateEnabled(enum, not disable_other_states)
        end
    end
end

function StateController:_bindUpdateMethodToEvent(eventName: RuntimeEventName?)

    eventName = if eventName then eventName else "RenderStepped"
    local valid = if table.find(RUNTIME_EVENT_NAMES, eventName) then true else false

    print("IS '"..eventName.."' a valid event? "..tostring(valid))

    if not RunService[eventName] then
        error("Invalid RuntimeEventName '"..eventName.."'")
    end

    if self.current_update_conn then
        --print("disconnecting previous update conn")
        self.current_update_conn:Disconnect()
    end

    self.current_update_conn = RunService[eventName]:Connect(function(deltaTime)
        --print("firing grinding:_fireCurrentStateUpdateMethod")
        self:_fireCurrentStateUpdateMethod(deltaTime)
    end)
end

function StateController:_fireCurrentStateUpdateMethod(deltaTime)
    --print("updating '"..self.client_data.current_state.."' state")
    local before = os.clock()
    self.client_data.current_state_module:update(deltaTime)
    local after = os.clock()

    table.insert(self.client_data.update_log[self.client_data.current_state], after - before)
end

function StateController:SilenceState(state: types.CharacterState, duration: number?)
    duration = duration or 0.5
    if self.client_data.mute_log[state] then
        self.client_data.mute_log[state] = os.clock() + duration
    end

    print("SILENCED '"..state.."' STATE")
    task.delay(duration, function()
        print("RE-ENABLED '"..state.."' STATE")
    end)
end

function StateController:UpdateMacro(name: string, value: any?)
    if not self.client_data.macros[name] and self.client_data.macros[name] ~= false then
        warn("[StateController:UpdateMacro] Cannot locate macro named '"..name.."'")
        return
    end

    self.client_data.macros[name] = value
    self.macro_handler_modules[name]:on_change(value)
end

function StateController:GetState(): types.CharacterState
    return self.client_data.current_state
end

function StateController:ChangeState(state: types.CharacterState, ...: any)

    if self.client_data.current_state == state then return end

    local function PushStateToBuffer()
        if #self.client_data.state_log >= MAX_LOG_ENTRIES then
            self._janitor:Add(function()
                table.remove(self.client_data, 1)
            end)
            self._janitor:Cleanup()
        end

        table.insert(self.client_data.state_log, {
            target_state = self.client_data.current_state,
            activation_time = self.client_data.activation_time
        } :: LogEntry )
    end

    -- check if new state is currently silenced
    local activation_time = os.clock()
    if self.client_data.mute_log[state] > activation_time then return end

    -- end current state module
    local transfer_data = {}
    if self.client_data.current_state_module then
        transfer_data = self.client_data.current_state_module:on_end() or {}
        PushStateToBuffer()
    end
    
    for _, v in {...} do
        table.insert(transfer_data, v)
    end

    -- set state
    self.client_data.current_state = state
    self.client_data.activation_time = activation_time

    -- start new state module
    self:_setHumanoidOverrides()
    self.client_data.current_state_module = self.state_handler_modules[state]
    self.client_data.current_state_module:on_start(transfer_data)

    -- fire state changed signal
    self.state_changed:Fire()

    -- run render stepped functions
    self:_bindUpdateMethodToEvent(self.client_data.current_state_module.RuntimeEvent)
end

function StateController:KnitInit()
    PlayerCore = Knit.GetController("PlayerCore")

    self._janitor = Janitor.new()
    self.state_changed = Signal.new()
    self.client_data = {
        current_state = "idle",
        state_log = {},
        update_log = {},
        mute_log = {},
        macros = {
            accelerating = false,
            crouching = false,
            jumping = false
        },
    }

    self.state_handler_modules = {}
    for _, state_module in state_handlers:GetChildren() do
        print(state_module.Name)
        self.state_handler_modules[state_module.Name] = require(state_module):init()
        self.client_data.update_log[state_module.Name] = {0}
        self.client_data.mute_log[state_module.Name] = 0
    end

    self.macro_handler_modules = {}
    for _, macro_module in macro_handlers:GetChildren() do
        print(macro_module.Name)
        self.macro_handler_modules[macro_module.Name] = require(macro_module):init()
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        if self.client_data.current_state_module and self.client_data.current_state_module.update then

            if #self.client_data.update_log[self.client_data.current_state] >= MAX_STATE_UPDATE_ENTRIES then
                self._janitor:Add(function()
                    table.remove(self.client_data.update_log[self.client_data.current_state], 1)
                end)
                self._janitor:Cleanup()
            end
        end
    end)
end


return StateController