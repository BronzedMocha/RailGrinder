local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Shared")
local Bezier = require(shared_folder.modules.Bezier)
local RailFolder = workspace.Rails

local function getOrderedTupleFromInstance(from: Instance)
	local output = {}

	for _, v in from:GetChildren() do
		local number_from_name = string.gsub(v.Name, "%D", "")
		local string_to_number = tonumber(number_from_name)
		
		if not string_to_number then warn("Removing part '"..v.Name.."' from bezier generation. Name needs a number!") continue end

		local id = math.floor(string_to_number) -- floored to force enforce basic table
		if not output[id] then
			output[id] = v
		else
			warn("Removing part '"..v.Name.."' from bezier generation. No duplicate numbered items allowed!")
		end
	end
	return table.unpack(output)
end

for index, BezierFolder in RailFolder:GetChildren() do
	local NewBezier = Bezier.new(getOrderedTupleFromInstance(BezierFolder))

	local NumPoints = 20
	local Points = {}
	local Attachments = {}

	local SegmentsFolder = Instance.new("Folder", BezierFolder)
	SegmentsFolder.Name = "Segments"

	local PointsRootInstance = Instance.new("Part", BezierFolder)
	PointsRootInstance.Name = "Points"
	PointsRootInstance.Anchored = true
	PointsRootInstance.CanCollide = false
	PointsRootInstance.CanTouch = false
	PointsRootInstance.CanQuery = false
	PointsRootInstance.Transparency = 1

	local completedValue = Instance.new("BoolValue", BezierFolder)
	completedValue.Name = "AreRailsLoaded"
	completedValue.Value = false

	for i = 1, NumPoints do
		local TargetPart = Instance.new("Part", SegmentsFolder)
		TargetPart.Name = i
		TargetPart.Size = Vector3.new(0.75, 0.75, 3)
		TargetPart.Color = BezierFolder.P1.Color
		TargetPart.CanCollide = false
		TargetPart.Anchored = true
		TargetPart:SetAttribute("isRail", true)
		table.insert(Points, TargetPart)

		local TargetAttachment = Instance.new("Attachment", PointsRootInstance)
		TargetAttachment.Visible = true
		TargetAttachment.Name = i
		table.insert(Attachments, i, TargetAttachment)
	end

	local Lines = {}
	for i = 1, NumPoints - 1 do
		local TargetPart = Instance.new("Part", SegmentsFolder)
		TargetPart.Size = Vector3.new(0.5, 0.5, 1)
		TargetPart.Color = BezierFolder.P1.Color:Lerp(Color3.new(), 0.9)
		TargetPart.CanCollide = false
		TargetPart.Anchored = true
		table.insert(Lines, TargetPart)
	end


	--while task.wait() do
		for i = 1, #Points do
			local t = (i - 1) / (#Points - 1)
			-- calculates the position and derivative of the Bezier Curve at t
			local position = NewBezier:CalculatePositionAt(t)
			local derivative = NewBezier:CalculateDerivativeAt(t)
			-- sets the position and orientation of the point based on the 
			-- position and derivative of the Bezier Curve
			Points[i].CFrame = CFrame.new(position, position + derivative)

			Attachments[i].WorldCFrame = Points[i].CFrame

		end
		for i = 1, #Lines do
			local line = Lines[i]
			local p1, p2 = Points[i].Position, Points[i + 1].Position
			line.Size = Vector3.new(line.Size.X, line.Size.Y, (p2 - p1).Magnitude)
			line.CFrame = CFrame.new(0.5 * (p1 + p2), p2)
		end
	--end

	-- set transparency
	for _, splinePoint: Part in BezierFolder:GetChildren() do
		if splinePoint:IsA("Part") then
			splinePoint.Transparency = 0.8
		end
	end

	completedValue.Value = true
end



