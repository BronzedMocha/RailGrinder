-- # selene: allow(if_same_then_else)
-- # selene: allow(unused_variable)
-- # selene: allow(shadowing)

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Oklab = require(Package.Colour.Oklab)

local function lerpType(from, to, ratio)
	local typeString = typeof(from)

	if typeof(to) == typeString then
		if typeString == "number" then
			local to, from = to, from

			return (to - from) * ratio + from
		elseif typeString == "CFrame" then
			local to, from = to, from

			return from:Lerp(to, ratio)
		elseif typeString == "Color3" then
			local to, from = to, from
			local fromLab = Oklab.to(from)
			local toLab = Oklab.to(to)

			return Oklab.from(fromLab:Lerp(toLab, ratio), false)
		elseif typeString == "ColorSequenceKeypoint" then
			local to, from = to, from
			local fromLab = Oklab.to(from.Value)
			local toLab = Oklab.to(to.Value)

			return ColorSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				Oklab.from(fromLab:Lerp(toLab, ratio), false)
			)
		elseif typeString == "DateTime" then
			local to, from = to, from

			return DateTime.fromUnixTimestampMillis(
				(to.UnixTimestampMillis - from.UnixTimestampMillis) * ratio + from.UnixTimestampMillis
			)
		elseif typeString == "NumberRange" then
			local to, from = to, from

			return NumberRange.new((to.Min - from.Min) * ratio + from.Min, (to.Max - from.Max) * ratio + from.Max)
		elseif typeString == "NumberSequenceKeypoint" then
			local to, from = to, from

			return NumberSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				(to.Value - from.Value) * ratio + from.Value,
				(to.Envelope - from.Envelope) * ratio + from.Envelope
			)
		elseif typeString == "PhysicalProperties" then
			local to, from = to, from

			return PhysicalProperties.new(
				(to.Density - from.Density) * ratio + from.Density,
				(to.Friction - from.Friction) * ratio + from.Friction,
				(to.Elasticity - from.Elasticity) * ratio + from.Elasticity,
				(to.FrictionWeight - from.FrictionWeight) * ratio + from.FrictionWeight,
				(to.ElasticityWeight - from.ElasticityWeight) * ratio + from.ElasticityWeight
			)
		elseif typeString == "Ray" then
			local to, from = to, from

			return Ray.new(from.Origin:Lerp(to.Origin, ratio), from.Direction:Lerp(to.Direction, ratio))
		elseif typeString == "Rect" then
			local to, from = to, from

			return Rect.new(from.Min:Lerp(to.Min, ratio), from.Max:Lerp(to.Max, ratio))
		elseif typeString == "Region3" then
			local to, from = to, from
			local position = from.CFrame.Position:Lerp(to.CFrame.Position, ratio)
			local halfSize = from.Size:Lerp(to.Size, ratio) / 2

			return Region3.new(position - halfSize, position + halfSize)
		elseif typeString == "Region3int16" then
			local to, from = to, from

			return Region3int16.new(
				Vector3int16.new(
					(to.Min.X - from.Min.X) * ratio + from.Min.X,
					(to.Min.Y - from.Min.Y) * ratio + from.Min.Y,
					(to.Min.Z - from.Min.Z) * ratio + from.Min.Z
				),
				Vector3int16.new(
					(to.Max.X - from.Max.X) * ratio + from.Max.X,
					(to.Max.Y - from.Max.Y) * ratio + from.Max.Y,
					(to.Max.Z - from.Max.Z) * ratio + from.Max.Z
				)
			)
		elseif typeString == "UDim" then
			local to, from = to, from

			return UDim.new(
				(to.Scale - from.Scale) * ratio + from.Scale,
				(to.Offset - from.Offset) * ratio + from.Offset
			)
		elseif typeString == "UDim2" then
			local to, from = to, from

			return from:Lerp(to, ratio)
		elseif typeString == "Vector2" then
			local to, from = to, from

			return from:Lerp(to, ratio)
		elseif typeString == "Vector2int16" then
			local to, from = to, from

			return Vector2int16.new((to.X - from.X) * ratio + from.X, (to.Y - from.Y) * ratio + from.Y)
		elseif typeString == "Vector3" then
			local to, from = to, from

			return from:Lerp(to, ratio)
		elseif typeString == "Vector3int16" then
			local to, from = to, from

			return Vector3int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y,
				(to.Z - from.Z) * ratio + from.Z
			)
		end
	end
	if ratio < 0.5 then
		return from
	else
		return to
	end
end

return lerpType
