local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))
local TableUtil = require(packages:WaitForChild("TableUtil"))
local Signal = require(packages:WaitForChild("Signal"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Iris = require(packages:WaitForChild("Iris"))

local types = require(shared_folder:WaitForChild("types"))

local DebugVisualize = require(shared_folder.modules.DebugVisualize)

local ui = shared_folder:WaitForChild("ui")
local iris_ui = ui:WaitForChild("iris")
local iris_widgets = iris_ui:WaitForChild("widgets")

local IrisProfiler = Knit.CreateController { Name = "IrisProfiler" }


local StateController
local InputListener
local PlayerCore

local function RoundByScalar(num: number, scalar: number)
    if not num or not scalar then return 0 end
    return math.floor(num * (1/scalar) + 0.5) / (1/scalar)
end

local function findSmallestDigit(num: number)
    -- Convert the number to a string
    local numStr = tostring(num)
    
    -- Find the position of the decimal point
    local decimalPos = string.find(numStr, "%.")
    
    if decimalPos then
        -- Calculate the number of digits after the decimal point
        local decimalPlaces = #numStr - decimalPos
        
        -- The smallest digit is 1 followed by zeros equal to the number of decimal places - 1
        return 1 / (10 ^ decimalPlaces)
    else
        -- If there is no decimal point, the smallest digit is 1
        return 1
    end
end

local function GetLengthOfDictionary(dict)
    local i = 0
    for _, value in dict do
        i = i + 1
    end
    return i
end

-- Ramer-Douglas-Peucker algorithm for polyline simplification
local function simplifyGraphPoints(points, epsilon)
    -- Calculate the perpendicular distance from a point to a line
    local function pointToLineDistance(i, l1, l2)
        local x = i
        local y = l1
        local num = math.abs((l2 - l1) * x - (l2 - l1) * y + l2 * 1 - l2 * l1)
        local den = math.sqrt((l2 - l1) ^ 2 + (1) ^ 2)
        return num / den
    end

    local result = {}
    local dmax = 0
    local index = 0

    local n = #points
    local startIdx, endIdx = 1, n

    for i = 2, n - 1 do
        local d = pointToLineDistance(points[i], points[startIdx], points[endIdx])

        if d > dmax then
            index = i
            dmax = d
        end
    end

    if dmax > epsilon then
        local recResults1 = simplifyGraphPoints({table.unpack(points, 1, index)}, epsilon)
        local recResults2 = simplifyGraphPoints({table.unpack(points, index, n)}, epsilon)

        table.move(recResults1, 1, #recResults1, #result + 1, result)
        table.move(recResults2, 1, #recResults2, #result + 1, result)
    else
        result = {points[startIdx], points[endIdx]}
    end

    return result
end

function IrisProfiler:BindMovementVectorToMenu()
    self.iris_values.movement_vector:set(InputListener.movement_vector)
end

function IrisProfiler:CreatePanel(index: string, panel_name: string, data: {[string]: any?}, metadata: {[string]: {}})
    
    local function getArgTableFromMetadata(param, elementName)
        local result = {}
        for param_name, value in param do
            if Iris.Args[elementName][param_name] then
                result[Iris.Args[elementName][param_name]] = value
            end
        end
        return result
    end
    
    self.panels[index] = {}

    self.panels[index].state_values = {};
    self.panels[index].func = function()
        Iris.Tree({panel_name})
        -- load data
        for name, value in data do
            self.panels[index].state_values[name] = Iris.State(value)
            self.panels[index].state_values[name]:onChange(function()
                self.onPanelSettingChanged:Fire(index, name, self.panels[index].state_values[name]:get())
            end)

            if typeof(value) == "number" then
                local args = if metadata[name] then getArgTableFromMetadata(metadata[name], "DragNum") else {}
                args[Iris.Args.DragNum.Increment] = findSmallestDigit(value)
                Iris.DragNum({name}, {number = self.panels[index].state_values[name]})
            elseif typeof(value) == "boolean" then
                local args = if metadata[name] then getArgTableFromMetadata(metadata[name], "Checkbox") else nil
                Iris.Checkbox({name, args}, {isChecked = self.panels[index].state_values[name]})
            elseif typeof(value) == "Vector2" then
                local args = if metadata[name] then getArgTableFromMetadata(metadata[name], "DragVector2") else nil
                Iris.DragVector2({name, args}, {number = self.panels[index].state_values[name]})
            end
        end
        Iris.End()
    end
end

function IrisProfiler:KnitStart()
    local current_state_value = Iris.State("init")
    local previous_state_values
    local previous_state_elapsed_values

    local function bindHumanoidStateToIris(char)
        self.iris_values.humanoid_state:set(string.lower(PlayerCore.humanoid:GetState().Name))
        PlayerCore.humanoid.StateChanged:Connect(function(old: EnumItem, new: EnumItem)
            -- print(new.Name)
            self.iris_values.humanoid_state:set(string.lower(new.Name))
        end)
    end

    local function InfoPanel()
        Iris.Tree({ "Info Panel" }, {isUncollapsed = Iris.State(true)})

            -- state
            Iris.SeparatorText({"Current State"})
            Iris.SameLine()
                Iris.Text({current_state_value.value})
                Iris.PushConfig({TextTransparency = 0.5})
                Iris.Text({" / "})
                Iris.Text({self.iris_values.humanoid_state.value})
                Iris.PopConfig()
            Iris.End()


            -- debugging enabled
            -- local checkbox = Iris.Checkbox({"Debugger Enabled"})
            -- self.iris_values.debugging_enabled = checkbox.isChecked

            -- debugging enabled
            Iris.Checkbox({"Debug Visuals"}, {isChecked = self.iris_values.debug_visuals_enabled})
            
            -- movement vector
            Iris.InputVector2({"Input Direction"}, {number = self.iris_values.movement_vector})

            -- vector size
            Iris.InputVector2({"Window Size"}, {number = self.iris_values.window_size})

            -- vector size
            Iris.InputVector2({"Window Position"}, {number = self.iris_values.window_position})
        Iris.End()
    end

    local function CurrentState()
        current_state_value:set(StateController.client_data.current_state)
        previous_state_values = {}
        previous_state_elapsed_values = {}
        --local update_log_graph_data = {}

        for i = 1, 8 do
            previous_state_values[i] = Iris.State(
                if StateController.client_data.state_log[#StateController.client_data.state_log - (i-1)] then
                    StateController.client_data.state_log[#StateController.client_data.state_log - (i-1)].target_state
                else
                    "n/a"
            )
            previous_state_elapsed_values[i] = Iris.State("")
            --update_log_graph_data[i] = Iris.State({})
        end

        StateController.state_changed:Connect(function()

            for i = 8, 2, -1 do
                --update_log_graph_data[i]:set(TableUtil.Copy(update_log_graph_data[i-1]))
                --print(update_log_graph_data[i])
            end

            -- grab buffer from current state, simplify data for graph
            --update_log_graph_data[1]:set(simplifyGraphPoints(TableUtil.Copy(StateController.client_data.update_log[StateController.client_data.current_state]), 0.15))

            current_state_value:set(StateController.client_data.current_state)

            for i = 8, 1, -1 do
                local state_log_index = #StateController.client_data.state_log - (i-1)

                -- print("Previous State "..i..": ")

                if not StateController.client_data.state_log[state_log_index] then
                    continue
                end

                -- print(StateController.client_data.state_log[#StateController.client_data.state_log - (i-1)].target_state)

                previous_state_values[i]:set(StateController.client_data.state_log[state_log_index].target_state)

                -- time
                --local next_state_activation_time = if i == 1 then StateController.client_data.activation_time else StateController.client_data.state_log[state_log_index+1].activation_time
                --local elapsed = next_state_activation_time - StateController.client_data.state_log[state_log_index].activation_time
                --previous_state_elapsed_values[i]:set("("..RoundByScalar(elapsed, 0.01).." seconds)")
            end
        end)

        Iris.Tree({"State Log"}, {isUncollapsed = self.iris_values.debugging_enabled})
            Iris.SeparatorText({"Current State"})
            Iris.Text({current_state_value.value})
            Iris.SeparatorText({"Previous States"})
            for i = 1, #previous_state_values do
                Iris.SameLine()
                    Iris.Text({previous_state_values[i].value})
                    
                    Iris.PushConfig({ TextColor = Color3.new(0.5, 0.5, 0.5) })
                    Iris.Text({previous_state_elapsed_values[i].value})
                    Iris.PopConfig()
                    
                    --Iris.LineGraph({update_log_graph_data[i].value, 30})

                Iris.End()
            end
        Iris.End()
    end

    local function CharacterStateLog()
        --[[
            should look like this:

            State      | AvgTime     90%         25%
            ---------------------------------------------
            Idle       | 18 m/s      18 m/s      18 m/s
            Walking    | 18 m/s      18 m/s      18 m/s
            Jumping    | 18 m/s      18 m/s      18 m/s
            Landing    | 18 m/s      18 m/s      18 m/s
            Grinding   | 18 m/s      18 m/s      18 m/s
            Freefall   | 18 m/s      18 m/s      18 m/s
            Catching   | 18 m/s      18 m/s      18 m/s
        ]]

        Iris.Tree({ "State Benchmarker" }, {isUncollapsed = self.iris_values.debugging_enabled})
        
            local numberOfStates = GetLengthOfDictionary(StateController.client_data.update_log)
            Iris.SeparatorText({"state_module.update() Execution Time"})
            Iris.Table({[Iris.Args.Table.NumColumns] = 4})

            for _, text in {"State", "avg ms", "90%", "25%"} do
                Iris.Text({text})
                Iris.NextColumn()
            end

                --Iris.NextRow()
                --Iris.SetColumnIndex(1)

                for state_name, data in StateController.client_data.update_log do
                    
                    table.sort(data, function(a, b)
                        return a > b
                    end)

                    -- name
                    Iris.Text({state_name})
                    Iris.NextColumn()

                    -- average
                    local sum = 0
                    for _, element in pairs(data) do
                        sum += element
                    end

                    local average_data_index = sum/#data
                    local average = tostring(RoundByScalar(average_data_index, 0.01))
                    Iris.Text({average.." /ms"})
                    Iris.NextColumn()


                    -- 90%
                    --Iris.Text({state_name})
                    local percentile90_data_index = data[math.floor(#data * 0.9)]
                    local percentile90 = tostring(RoundByScalar(percentile90_data_index, 0.01))
                    Iris.Text({percentile90.." /ms"})
                    --Iris.Text({tostring(data[math.floor(#data * 0.9)]).. "/ms"})
                    Iris.NextColumn()

                    -- 25%
                    --Iris.Text({state_name})
                    local percentile25_data_index = data[math.floor(#data * 0.25)]
                    local percentile25 = tostring(RoundByScalar(percentile25_data_index, 0.01))
                    Iris.Text({percentile25.." /ms"})
                    Iris.NextColumn()
                    --Iris.SetColumnIndex(1)
                    --Iris.NextRow()
                end

            Iris.End()
        Iris.End()
    end

    bindHumanoidStateToIris()
    PlayerCore.character_spawned:Connect(bindHumanoidStateToIris)

    Iris:Connect(function()
        Iris.Window({"Debugger"}, {size = self.iris_values.window_size, position = self.iris_values.window_position})
            InfoPanel()
            CurrentState()
            CharacterStateLog()

            for _, panel in self.panels do
                panel.func()
            end

        Iris.End()

        --[[Iris.Window({"Quick Stats", [Iris.Args.Window.NoTitleBar] = true, [Iris.Args.Window.NoCollapse] = true, [Iris.Args.Window.NoResize] = true, [Iris.Args.Window.NoScrollbar] = false}, {size = Vector2.new(200, 183), position = Vector2.new(1, 78)})
            Iris.Tree({"State Log", [Iris.Args.Tree.SpanAvailWidth] = true, [Iris.Args.Tree.NoIndent] = true}, {isUncollapsed = true})
                
                -- render current state + humanoid state
                Iris.SameLine()
                    Iris.Text({current_state_value.value})
                    Iris.PushConfig({TextTransparency = 0.5})
                    Iris.Text({"/"})
                    Iris.Text({self.iris_values.humanoid_state.value})
                    Iris.PopConfig()

                Iris.End()

                -- render previous states
                for i = 1, #previous_state_values do
                    Iris.SameLine()
                        Iris.Text({previous_state_values[i].value})
                        
                        Iris.PushConfig({ TextColor = Color3.new(0.5, 0.5, 0.5) })
                        Iris.Text({previous_state_elapsed_values[i].value})
                        Iris.PopConfig()
                        
                        --Iris.LineGraph({update_log_graph_data[i].value, 30})

                    Iris.End()
                end
            Iris.End()
        Iris.End()]]
    end)
end


function IrisProfiler:KnitInit()
    StateController = Knit.GetController("StateController")
    InputListener = Knit.GetController("InputListener")
    PlayerCore = Knit.GetController("PlayerCore")

    self.onPanelSettingChanged = Signal.new()

    self.iris_values = {
        window_size = Iris.State((Vector2.new(350, math.floor(workspace.CurrentCamera.ViewportSize.Y * 0.75)))),
        window_position = Iris.State(),
        movement_vector = Iris.State(Vector2.new());
        debugging_enabled = nil, -- created in InfoPanel -> 'Debugging Enabled' checkbox
        debug_visuals_enabled = Iris.State(true),
        humanoid_state = Iris.State("init"),
    }
    self.panels = {}
    self.iris_values.window_position:set(workspace.CurrentCamera.ViewportSize - Vector2.new(2, 2) - self.iris_values.window_size:get())

    self.iris_values.debug_visuals_enabled:onChange(function(to: boolean)
        DebugVisualize.enabled = to
    end)
    
end


return IrisProfiler