local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local types = require(shared_folder:WaitForChild("types"))

local RailManager = require(shared_folder.modules.RailManager)
local DebugVisualize = require(shared_folder.modules.DebugVisualize)

local packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(packages:WaitForChild("Janitor"))
local Knit = require(packages:WaitForChild("Knit"))

local PlayerCore
local IrisProfiler
local InputListener
local StateController

local grinding = {}

export type Rail = {
    points: {Attachment},
    segments: {BasePart}
}

local SURFACE_ANGLE_SCALAR = 2
local FRICTION_SCALAR = 0.08

local RAIL_TRANSITION_MAX_DIST = 0.1

local clamp, deg, acos, vnew, cfnew, cfmat, clook = math.clamp, math.deg, math.acos, Vector3.new, CFrame.new, CFrame.fromMatrix, CFrame.lookAt

local rightV = vnew(1, 0, 0)
local upV = vnew(0, 1, 0)
local downV = vnew(0, -1, 0)
local lookV = vnew(0, 0, 1)

function grinding._lerp(a: number, b: number, alpha: number)
    return a + (b - a) * alpha
end

function grinding._getRayAttachmentLookCFrame(RaycastResult: RaycastResult) -- Luanoid, from LPGhatguy, jovannic, and Fraktality (github usernames) 
		
    -- returns WORLD CFRAME with UP vector positioned to the normal!!!
    
    local object = RaycastResult.Instance
    local position = RaycastResult.Position
    local normal = RaycastResult.Normal -- look at the collision point
    
    local worldPosition = position
    local part = object 
    -- TODO: terrible behavior if look colinear with up (use character up instead?)
    local zAxis = Vector3.new(0, 1, 0) -- up
    local yAxis = normal -- -look (look is -z)
    local xAxis = yAxis:Cross(zAxis).Unit -- right
    -- orthonormalize, keeping look vector
    yAxis = zAxis:Cross(xAxis).Unit
    return part.CFrame:inverse() * CFrame.new(
        worldPosition.x, worldPosition.y, worldPosition.z,
        xAxis.X, yAxis.X, zAxis.X,
        xAxis.Y, yAxis.Y, zAxis.Y,
        xAxis.Z, yAxis.Z, zAxis.Z
    )

    --[[
        local yAxis = normal -- up
        local zAxis = Vector3.new(normal.X, normal.Z, -normal.Y) -- look
        local xAxis = yAxis:Cross(zAxis).Unit -- right
        -- orthonormalize, keeping look vector
        yAxis = zAxis:Cross(xAxis).Unit
        return part.CFrame:inverse() * CFrame.new(
            worldPosition.x, worldPosition.y, worldPosition.z, 
            xAxis.X, yAxis.X, zAxis.X, 
            xAxis.Y, yAxis.Y, zAxis.Y, 
            xAxis.Z, yAxis.Z, zAxis.Z)

    ]]
end

function grinding._GetClosestPointOnLine(lineStart: Vector3, lineEnd: Vector3, point: Vector3): Vector3
    local lineDirection = (lineEnd - lineStart).Unit
    local lineVector = lineEnd - lineStart
    local pointVector = point - lineStart

    local dotProduct = pointVector:Dot(lineVector)
    local t = math.clamp(dotProduct / lineVector.Magnitude^2, 0, 1)

    local closestPoint = lineStart + lineVector * t
    return closestPoint
end

function grinding._SetupPhysicsObjects(character: Model, RaycastResult: RaycastResult, rootOffset: Vector3?)
    local position0 = Instance.new("Attachment")
	position0.Position = rootOffset or vnew(0, 0, 0)
    position0.Name = "grinding_position0"
	position0.Parent = character.PrimaryPart

	local position1 = Instance.new("Attachment")
    position1.Name = "grinding_position1"
	position1.CFrame = grinding._getRayAttachmentLookCFrame(RaycastResult)
	position1.Parent = RaycastResult.Instance

	local align_position = Instance.new("AlignPosition")
	align_position.Attachment0 = position0
	align_position.Attachment1 = position1
	align_position.MaxForce = 100000
	align_position.Responsiveness = 50
	align_position.MaxVelocity = 7
    align_position.RigidityEnabled = true
	align_position.Parent = character.PrimaryPart

	local align_orientation = Instance.new("AlignOrientation")
	align_orientation.Attachment0 = position0
	align_orientation.Attachment1 = position1
    align_orientation.Responsiveness = 50
	align_orientation.Parent = character.PrimaryPart

    return position0, position1, align_position, align_orientation
end

-----------------------------------------------

function grinding:_destroyPhysics()
    if self.position0 then self.position0:Destroy() end
    if self.position1 then self.position1:Destroy() end
    if self.align_pos then self.align_pos:Destroy() end
    if self.align_ori then self.align_ori:Destroy() end
end

function grinding:init(core: types.CharacterCore?)
    PlayerCore = core or Knit.GetController("PlayerCore")
    IrisProfiler = Knit.GetController("IrisProfiler")
    InputListener = Knit.GetController("InputListener")
    StateController = Knit.GetController("StateController")

    local self = {
        HumanoidStateConfig = { -- overrides roblox state to force specific states to exist
            [Enum.HumanoidStateType.PlatformStanding] = true;
        };
        RuntimeEvent = "Heartbeat" :: types.RuntimeEventName;
    }

    self.grind_stats = {
        InputPower = 1,
        SlopeInfluence = 1,
        RotationalStiffness = 0.5,
        FrictionStiffness = 0.5,
        FrictionInfluence = 1,
        Gravity = 1,
        SmoothnessScalar = 0.01,
    }

    self.connections = {}
    self.last_time_in_grinding_state = 0

    self._janitor = Janitor.new()

    setmetatable(self, {__index = grinding})

    Knit.OnStart():andThen(function()
        IrisProfiler:CreatePanel(script.Name, "Grinding Info", self.grind_stats, {
            SmoothnessScalar = {Min = 0; Max = 1}
        })
        
        IrisProfiler.onPanelSettingChanged:Connect(function(index, param_name, new_value)
            if index == script.Name and self.grind_stats[param_name] and self.grind_stats[param_name] ~= new_value then
                print("setting", param_name, "to:", tostring(new_value))
                self.grind_stats[param_name] = new_value
            end
        end)

    end):catch(warn)

    return self
end

function grinding:_getPoint(index)
    print("is there a point at index '"..tostring(index).."'? "..(if self.rail.points[index] then "YES" else "NO"))
    return self.rail.points[index]
end

function grinding:_setPoint(point0_index)
    local reached_end = if self.rail.points[point0_index] and self.rail.points[point0_index + 1] then false else true
    if reached_end then
        -- force jump off
        print("you reached the end!!!")

        if not self.rail.points[point0_index + 1] then
            print("point1index '"..tostring(point0_index + 1).."' does not exist")
        elseif not self.rail.points[point0_index] then
            print("point0index '"..(point0_index).."' does not exist")
        end

        StateController:SilenceState("grinding")
        StateController:ChangeState("jumping", true)
        return
    end

    print("setting new point0 from '"..tostring(self.point0_index).."' to '"..tostring(point0_index).."'")

    self.point0_index = point0_index
    self.point1_index = point0_index + 1
end

function grinding:_validatePoints()
    local point0 = self:_getPoint(self.point0_index)
    local point1 = self:_getPoint(self.point1_index)

    if not point0 and not point1 then
        local nearest_point0, nearest_point1 = RailManager.utility.findNearestPoints(self.position0.WorldCFrame.Position, self.rail.points)
        self:_setPoint(nearest_point0)
        return self:_validatePoints()
    elseif not point0 then
        self:_setPoint(self.point1_index)
        return self:_validatePoints()
    elseif not point1 then
        self:_setPoint(self.point0_index - 1)
        return self:_validatePoints()
    end

    return point0, point1
end

function grinding:CheckPointDistance()

    local point0, point1 = self:_validatePoints()

    local point0_pos = point0.WorldCFrame.Position
    local point1_pos = point1.WorldCFrame.Position
    local player_pos = self.position0.WorldCFrame.Position -- - vnew(0, -PlayerCore.measurements.ROOT_HEIGHT, 0)

    local full_distance = (point1_pos - point0_pos).Magnitude
    local dist_from0 = (player_pos - point0_pos).Magnitude
    local dist_from1 = (player_pos - point1_pos).Magnitude

    local past_point1 = full_distance < dist_from0
    local before_point0 = full_distance < dist_from1

    local SUCCESS_COLOR = Color3.new(0.121568, 0.501960, 0.172549)
    local FAILURE_COLOR = Color3.new(0.501960, 0.121568, 0.121568)

    --[[ point0 to position1
    DebugVisualize.vector(
        (point0_pos + player_pos)/2,
        point0_pos - player_pos,
        if before_point0 then FAILURE_COLOR else SUCCESS_COLOR
    )

    -- point1 to position1
    DebugVisualize.vector(
        (point1_pos + player_pos)/2,
        point1_pos - player_pos,
        if past_point1 then FAILURE_COLOR else SUCCESS_COLOR
    )]]

    if past_point1 then
        self:_setPoint(self.point1_index)
    end

    if before_point0 then
        self:_setPoint(self.point0_index - 1)
    end
end

function grinding:update(dt: number)
    
    if not self.rail then return end

    -- set points if needed

    self:CheckPointDistance()

    local point0_pos = self:_getPoint(self.point0_index).WorldCFrame.Position
    local point1_pos = self:_getPoint(self.point1_index).WorldCFrame.Position

    DebugVisualize.sphere(cfnew(point0_pos), 0.5, Color3.new(0.12, 0.34, 0.5))
    DebugVisualize.sphere(cfnew(point1_pos), 0.5, Color3.new(0.29, 0.79, 1))

    -- get rail segment direction
    local rail_direction = (point0_pos - point1_pos).Unit

    local rail_up_dp = rail_direction:Dot(vnew(0,1,0))

    local slope_downward_angle = if rail_up_dp < 0 then rail_direction else -rail_direction
    print(rail_up_dp..(if rail_up_dp < 0 then ": gravity guides you toward the end" else ": gravity guides you towards the start"))
    
    -- derive gravity vector from rail direction (scale downward force by dot product of slope angle)
    local gravityForce = slope_downward_angle * (rail_up_dp * self.grind_stats.Gravity)

    -- derive input force from rail direction
    local rawInputVector = ((camera.CFrame.LookVector * InputListener.movement_vector.Y - camera.CFrame.RightVector * InputListener.movement_vector.X) * vnew(1, 0, 1)).Unit
    local input_rail_dp = rawInputVector:Dot(rail_direction * vnew(1, 0, 1))

    local inputForce = rail_direction * (input_rail_dp * self.grind_stats.InputPower) -- force disable
    if inputForce.X ~= inputForce.X then -- NaN check
        inputForce = vnew(0,0,0)
    end

    -- accumulate forces
    local velocity = inputForce + gravityForce
    local controlled_magnitude = grinding._lerp(self.last_velocity.Magnitude, velocity.Magnitude, self.grind_stats.SmoothnessScalar)

    velocity = velocity.Unit * controlled_magnitude

    -- TODO: check rail for friction (example: rail.segments[self.point0_index]:GetAttribute("Friction"))

    -- add friction
    --local frictionForce = ( (FRICTION_SCALAR * self.grind_stats.FrictionStiffness) * self.grind_stats.FrictionInfluence) * -velocity
    --velocity += frictionForce

    -- add to position
    local resulting_position = self.position0.WorldCFrame.Position + velocity
    
    self.position1.WorldCFrame = clook(resulting_position, resulting_position + velocity)
    
    self.last_velocity = velocity

    -- debug
    DebugVisualize.arrow(self.position0.WorldCFrame.Position, gravityForce, Color3.fromRGB(123, 0, 255))
    DebugVisualize.arrow(self.position0.WorldCFrame.Position, inputForce, Color3.fromRGB(0, 229, 255))
    DebugVisualize.arrow(self.position0.WorldCFrame.Position, velocity, Color3.fromRGB(255, 128, 0))
    --DebugVisualize.arrow(self.position0.WorldCFrame.Position, self.align_ori.PrimaryAxis, Color3.fromRGB(255, 0, 0))
    --DebugVisualize.arrow(self.position0.WorldCFrame.Position, self.align_ori.SecondaryAxis, Color3.fromRGB(255, 255, 0))

    --DebugVisualize.vector(self.position1.WorldCFrame.Position, gravityForce, Color3.new(0.047058, 0.635294, 1)) -- gravity
    --DebugVisualize.vector(self.position1.WorldCFrame.Position, inputForce, Color3.new(0.698039, 0.047058, 1)) -- input
    ----DebugVisualize.vector(self.position1.WorldCFrame.Position, frictionForce, Color3.new(1, 0.635294, 0.047058)) -- friction
    --DebugVisualize.vector(self.position1.WorldCFrame.Position, velocity, Color3.new(0.282352, 0.984313, 0.192156921)) -- accumulated

    --DebugVisualize.sphere(self.position1.WorldCFrame, 0.5, Color3.new(1, 0.098039, 0.098039), 0)
    DebugVisualize.sphere(cfnew(self.raycast_data.Position), 0.25, Color3.new(0.494117, 0.098039, 0.098039))

end

function grinding:on_start(landing_raycast_data: RaycastResult?)
    if not landing_raycast_data then print("no raycast data") return end

    PlayerCore.root.Anchored = true

    local land_position = landing_raycast_data.Position

    local RailId = landing_raycast_data.Instance:GetAttribute("RailId")
    local rail = RailManager:GetRailFromId(RailId)
    local point0_index, point1_index = RailManager.utility.findNearestPoints(landing_raycast_data.Position, rail.points)


    if not rail then print("no rail") return end

    -- get point1_index, if it exists
    if #rail.points <= point0_index then
        point1_index = point0_index+1
    end

    -- set current point
    self.point0_index = point0_index
    self.point1_index = point1_index
    self.rail = rail

    print("RAIL")
    print(self.rail)

    self.last_velocity = Vector3.new()

    -- force platform standing state
    PlayerCore.humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)

    -- setup alignPosition and alignOrientation on land position, hand over rail
    self.position0, self.position1, self.align_pos, self.align_ori = grinding._SetupPhysicsObjects(PlayerCore.character, landing_raycast_data, Vector3.new(0, -PlayerCore.measurements.ROOT_HEIGHT, 0))

    self._janitor:Add(self.position0)
    self._janitor:Add(self.position1)
    self._janitor:Add(self.align_pos)
    self._janitor:Add(self.align_ori)
    
    self.position1.WorldCFrame = CFrame.new(self._GetClosestPointOnLine(self.rail.points[self.point0_index].WorldCFrame.Position, self.rail.points[self.point1_index].WorldCFrame.Position, land_position))

    self.position0.Visible = true
    self.position1.Visible = true

    self.align_pos.Enabled = true
    self.align_ori.Enabled = true

    self.raycast_data = landing_raycast_data

    PlayerCore.root.Anchored = false

    print("complete!")
end

function grinding:on_end()
    self._janitor:Cleanup()
end

function grinding:destroy()

end

return grinding