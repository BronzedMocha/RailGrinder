-- MADE BY: ?

local Terrain = game:GetService("Workspace").Terrain

local unusedPoints = {}
local usedPoints = {}
local unusedVectors = {}
local usedVectors = {}
local unusedBlocks = {}
local usedBlocks = {}
local unusedSpheres = {}
local usedSpheres = {}
local usedArrowHeads = {}
local unusedArrowHeads = {}
local usedArrowBodies = {}
local unusedArrowBodies = {}

local DebugVisualize = {
	enabled = true;
    show_names = false; -- TODO: setup names on debugger

	ARROW_HEAD_SPACING = 0;
	ARROW_STACK_SPACING = 0.01;
}

local cnew, vnew = CFrame.new, Vector3.new

local function getArrowPositionAfterOffset(position: Vector3): Vector3
	local rightV
	local radius
	local amount_to_shift = 0
	for _, head: ConeHandleAdornment in usedArrowHeads do

		if (head.CFrame.Position - position).Magnitude <= 1 then
			amount_to_shift += 1
			if not rightV then
				rightV = head.CFrame.RightVector
				radius = head.Radius * 2
			end
		end
	end

	if amount_to_shift == 0 then
		return position
	else
		local offset = (rightV * (radius + DebugVisualize.ARROW_STACK_SPACING) * amount_to_shift)
		return position + offset
	end
end

function DebugVisualize.point(position: Vector3, color: Color3, name: string)
	if not DebugVisualize.enabled then
		return
	end

	local instance = table.remove(unusedPoints)

	if not instance then
		instance = Instance.new("SphereHandleAdornment")
		instance.ZIndex = 1
		instance.AlwaysOnTop = true
		instance.Radius = 0.12
		instance.Transparency = 0.25
		instance.Adornee = Terrain
		instance.Parent = Terrain
	end

	instance.Name = (name ~= nil) and "debug-"..name or "Debug Handle"
	instance.CFrame = cnew(position)
	instance.Color3 = color

	table.insert(usedPoints, instance)
end

function DebugVisualize.vector(position: Vector3, direction: Vector3, color: Color3, transparency: number)
	if not DebugVisualize.enabled then
		return
	end

	local instance = table.remove(unusedVectors)

	if not instance then
		instance = Instance.new("BoxHandleAdornment")
		instance.Color3 = Color3.new(1, 1, 1)
		instance.AlwaysOnTop = true
		instance.ZIndex = 2
		instance.Parent = Terrain
		instance.Adornee = Terrain
	end

	instance.CFrame = cnew(position, position + direction)
	instance.Color3 = color
	instance.Transparency = transparency or 0.25
	instance.Size = vnew(0.1, 0.1, math.max(direction.magnitude, 1))

	table.insert(usedVectors, instance)
end

function DebugVisualize.arrow(position: Vector3, direction: Vector3, color: Color3?, transparency: number?)
    if not DebugVisualize.enabled then
        return
    end

	--position = getArrowPositionAfterOffset(position) - doesn't work atm

    local arrowBody = table.remove(unusedArrowBodies)

    if not arrowBody then
        arrowBody = Instance.new("BoxHandleAdornment")
        arrowBody.Color3 = Color3.new(1, 1, 1)
        arrowBody.AlwaysOnTop = true
        arrowBody.ZIndex = 2
        arrowBody.Parent = game.Workspace.Terrain
        arrowBody.Adornee = game.Workspace.Terrain
    end

    local arrowHead = table.remove(unusedArrowHeads) -- Assuming you have a similar mechanism for arrow heads

    if not arrowHead then
        arrowHead = Instance.new("ConeHandleAdornment")
        arrowHead.Color3 = Color3.new(1, 1, 1)
        arrowHead.AlwaysOnTop = true
        arrowHead.ZIndex = 2
        arrowHead.Parent = game.Workspace.Terrain
        arrowHead.Adornee = game.Workspace.Terrain
    end

    local magnitude = direction.magnitude + 1
    local arrowBodyLength = math.max(magnitude - 0.5, 0.1) -- Ensure there's space for the arrowhead
    local arrowHeadSize = math.min(magnitude / 5, 0.5) -- Adjust arrowhead size based on vector length, with a max limit

    arrowBody.CFrame = cnew(position + direction/2, position + direction) * cnew(0, 0, -magnitude/2 + arrowBodyLength/2)
    arrowBody.Size = vnew(0.1, 0.1, arrowBodyLength)
    arrowBody.Transparency = transparency or 0.25

    --arrowHead.CFrame = cnew(position + (direction.Unit * magnitude), position + (direction.Unit * magnitude) * 1.01)
    arrowHead.CFrame = arrowBody.CFrame + (arrowBody.CFrame.LookVector * (arrowBodyLength/2 + DebugVisualize.ARROW_HEAD_SPACING))
	arrowHead.Height = arrowHeadSize
    arrowHead.Radius = arrowHeadSize / 2
    arrowHead.Transparency = transparency or 0.25

	if color then
		arrowBody.Color3 = color
		arrowHead.Color3 = color
	end

    table.insert(usedArrowBodies, arrowBody)
    table.insert(usedArrowHeads, arrowHead) -- Assuming there's a similar storage for arrow heads
end


function DebugVisualize.block(cf: CFrame, size: Vector3, color: Color3?, transparency: number?)
    if not DebugVisualize.enabled then
		return
	end

	local instance = table.remove(unusedBlocks)

	if not instance then
		instance = Instance.new("BoxHandleAdornment")
		instance.Color3 = Color3.new(1, 1, 1)
		instance.AlwaysOnTop = true
		instance.ZIndex = 2
		instance.Parent = Terrain
		instance.Adornee = Terrain
	end

	instance.CFrame = cf
	instance.Size = size
	instance.Color3 = color
	instance.Transparency = transparency or 0.25

	table.insert(usedBlocks, instance)
end

function DebugVisualize.sphere(cf: CFrame, radius: number, color: Color3?, transparency: number?)
    if not DebugVisualize.enabled then
		return
	end

	local instance = table.remove(unusedSpheres)

	if not instance then
		instance = Instance.new("SphereHandleAdornment")
		instance.Color3 = Color3.new(1, 1, 1)
		instance.AlwaysOnTop = true
		instance.ZIndex = 2
		instance.Parent = Terrain
		instance.Adornee = Terrain
	end

	instance.CFrame = cf
	instance.Radius = radius
	instance.Color3 = color
	instance.Transparency = transparency or 0.25

	table.insert(usedSpheres, instance)
end

function DebugVisualize.step()
	task.defer(function()
		while #unusedPoints > 0 do
			table.remove(unusedPoints):Destroy()
		end

		while #unusedVectors > 0 do
			table.remove(unusedVectors):Destroy()
		end

		while #unusedBlocks > 0 do
			table.remove(unusedBlocks):Destroy()
		end

		while #unusedSpheres > 0 do
			table.remove(unusedSpheres):Destroy()
		end

		while #unusedArrowHeads > 0 do
			table.remove(unusedArrowHeads):Destroy()
		end

		while #unusedArrowBodies > 0 do
			table.remove(unusedArrowBodies):Destroy()
		end

		usedPoints, unusedPoints = unusedPoints, usedPoints
		usedVectors, unusedVectors = unusedVectors, usedVectors
		usedBlocks, unusedBlocks = unusedBlocks, usedBlocks
		usedSpheres, unusedSpheres = unusedSpheres, usedSpheres
		usedArrowHeads, unusedArrowHeads = unusedArrowHeads, usedArrowHeads
		usedArrowBodies, unusedArrowBodies = unusedArrowBodies, usedArrowBodies
	end)
end

return DebugVisualize