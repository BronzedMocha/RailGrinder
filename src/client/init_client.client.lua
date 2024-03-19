local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))
local Iris = require(packages:WaitForChild("Iris"))

local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local tests = shared_folder:WaitForChild("tests")

local ui = shared_folder:WaitForChild("ui")
local iris_ui = ui:WaitForChild("iris")
local iris_widgets = iris_ui:WaitForChild("widgets")

-- basic wrapper to initialize Iris widgets
local function wrapper(name: string)
    return function(arguments, states)
        return Iris.Internal._Insert(name, arguments, states)
    end
end

-- initializing custom Iris widgets
for _, module in iris_widgets:GetChildren() do
    print(module.Name)
    Iris.Internal.WidgetConstructor(module.Name, require(module))
    Iris[module.Name] = wrapper(module.Name)
    print("added '"..module.Name.."' widget to Iris!")
end

-- initialize iris
Iris.Init()

-- initialize knit
local RailManager = require(shared_folder.modules.RailManager)
local Rail = workspace:WaitForChild("Rail")
local RailFolder = workspace:WaitForChild("Rails")

Knit.AddControllersDeep(script.Parent.controllers)
Knit.Start():andThen(function()
    -- marking knit controllers as loaded
    packages.Knit:SetAttribute("LoadedControllers", true)
    print("Knit started")
end):catch(function(err)
    warn(tostring(err))
end)

-- initializing testez for client
local TestEZ = require(packages:WaitForChild("TestEZ"))
TestEZ.TestBootstrap:run(tests.client:GetChildren())

-- initialize rail manager
for _, BezierFolder in RailFolder:GetChildren() do
    task.spawn(function()
        local SegmentsFolder = BezierFolder:WaitForChild("Segments")
        local PointsRootInstance = BezierFolder:WaitForChild("Points")

        while BezierFolder.AreRailsLoaded.Value == false do
            task.wait(.1)
        end
        
        -- create default rail
        RailManager:AddRail({
            points = PointsRootInstance:GetChildren(),
            segments = SegmentsFolder:GetChildren()
        })
    end)
end


