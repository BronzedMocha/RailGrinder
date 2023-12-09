-- MADE BY: CoderHusk, originally called Math++

local module = {
	phi = 1.6180339887,
	e = 2.718281828459,
	G = 6.673*10^-11,
	
	naturalLog = function(exp)
		return math.log(exp, 2.718281828459)
	end,
	bound = function(min,max,value)
		return (-max+value)/(-max + min)
	end,
	boundAlpha = function(min,max,value)
		return math.clamp((-max+value)/(-max + min), 0, 1)
	end,
	derivative = function(x,dx, func)
		return (func(x + dx) - func(x))/dx
	end,
	ellipse = function(minor,major,t)
		return {math.cos(2*t*math.pi - math.pi) * major, math.sin(2*t*math.pi - math.pi) * minor}
	end,
	sigmoid = function(z)
		return 1/(1 + 2.718281828459^-z)
	end,
	quadratic = function(a,b,c,t)
		return a*(t^2)+(b*t)+c
	end,
	integral = function(a, b, dx, func)
		local sum = 0
		for n=a,b,dx do
			sum += func(n)
		end
		return sum*dx
	end,
	sum = function(a,b, func)
		local sum = 0
		for i=a,b,1 do
			sum += func(i)
		end
		return sum
	end,
	prod = function(a,b, func)
		local sum = a
		for i=a+1,b,1 do
			sum *= func(i)
		end
		return sum
	end,
	lerp = function(a,b,t)
		return a+(b-a)*t
	end,
	quadBezier = function(timeStep, control1, control2, control3)
		return (1-timeStep)^2 * control1 + 2*(1-timeStep) * timeStep * control2 + timeStep^2 * control3
	end,
	cubicBezier = function(timeStep, control1, control2, control3, control4)
		return (1-timeStep)^3 * control1 + 3*(1-timeStep)^2 * control2 + 3*(1-timeStep) * timeStep^2*control2 + timeStep^3 * control4
	end,
	eucDist = function(a,b,state)
		if state == 2 then
			return math.sqrt(((a.X - b.X)^2 + (a.Y - b.Y)^2))
		elseif state == 3 then
			return math.sqrt(((a.X - b.X)^2 + (a.Y - b.Y)^2 + (a.Z - b.Z)^2))
		else
			error("out of bound dimensions, must specify 2d or 3d (2 or 3)")
		end
	end,
	manHatDist = function(a,b,state)
		if state == 2 then
			return math.abs(a.X - b.X) + math.abs(a.Y - b.Y)
		elseif state == 3 then
			return math.abs(a.X - b.X) + math.abs(a.Y - b.Y) + math.abs(a.Z - b.Z)
		else
			error("out of bound dimensions, must specify 2d or 3d (2 or 3)")
		end
	end,
	chebDist = function(a,b,state)
		if state == 2 then
			return math.max(math.abs(a.X - b.X), math.abs(a.Y - b.Y))
		elseif state == 3 then
			return math.max(math.abs(a.X - b.X), math.abs(a.Y - b.Y), math.abs(a.Z - b.Z))
		else
			error("out of bound dimensions, must specify 2d or 3d (2 or 3)")
		end
	end,
	reflect = function(normal, dir)
		return dir-2*(dir:Dot(normal))*normal
	end,
	mat4x4 = function(components)
		local matrix = {{},{},{},{}}
		for i1 = 1, 4 do
			matrix[1][i1] = components[0+i1]
		end
		for i2 = 1, 4 do
			matrix[2][i2] = components[4+i2]
		end
		for i3 = 1, 4 do
			matrix[3][i3] = components[8+i3]
		end
		for i4 = 1, 4 do
			matrix[4][i4] = components[12+i4]
		end
		return matrix
	end,

	-- CUSTOM
	
	getRayAttachmentCFrame = function(object, position, normal) -- Luanoid, from LPGhatguy, jovannic, and Fraktality (github usernames) 
		
		-- returns WORLD CFRAME!!!
		
		local normal = normal -- look at the collision point
		local worldPosition = position
		local part = object 
		-- TODO: terrible behavior if look colinear with up (use character up instead?)
		local yAxis = Vector3.new(0, 1, 0) -- up
		local zAxis = normal -- -look (look is -z)
		local xAxis = yAxis:Cross(zAxis).Unit -- right
		-- orthonormalize, keeping look vector
		yAxis = zAxis:Cross(xAxis).Unit
		return part.CFrame:inverse() * CFrame.new(
			worldPosition.x, worldPosition.y, worldPosition.z, 
			xAxis.x, yAxis.x, zAxis.x, 
			xAxis.y, yAxis.y, zAxis.y, 
			xAxis.z, yAxis.z, zAxis.z)
	end,

	getRayAttachmentLookCFrame = function(object, position, normal) -- Luanoid, from LPGhatguy, jovannic, and Fraktality (github usernames) 
		
		-- returns WORLD CFRAME with UP vector positioned to the normal!!!
		
		local normal = normal -- look at the collision point
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
			xAxis.x, yAxis.x, zAxis.x, 
			xAxis.y, yAxis.y, zAxis.y, 
			xAxis.z, yAxis.z, zAxis.z)

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
	end,

	solveIK = function(originCF, targetPos, l1, l2)	-- from LMH_Hutch
		-- build intial values for solving
		local localized = originCF:pointToObjectSpace(targetPos)
		local localizedUnit = localized.unit
		local l3 = localized.magnitude
		
		-- build a "rolled" planeCF for a more natural arm look
		local axis = Vector3.new(0, 0, -1):Cross(localizedUnit)
		local angle = math.acos(-localizedUnit.Z)
		local planeCF = originCF * CFrame.fromAxisAngle(axis, angle)
		
		-- case: point is to close, unreachable
		-- action: push back planeCF so the "hand" still reaches, angles fully compressed
		if l3 < math.max(l2, l1) - math.min(l2, l1) then
			return planeCF * CFrame.new(0, 0,  math.max(l2, l1) - math.min(l2, l1) - l3), -math.pi/2, math.pi
			
		-- case: point is to far, unreachable
		-- action: for forward planeCF so the "hand" still reaches, angles fully extended
		elseif l3 > l1 + l2 then
			return planeCF * CFrame.new(0, 0, l1 + l2 - l3), math.pi/2, 0
			
		-- case: point is reachable
		-- action: planeCF is fine, solve the angles of the triangle
		else
			local a1 = -math.acos((-(l2 * l2) + (l1 * l1) + (l3 * l3)) / (2 * l1 * l3))
			local a2 = math.acos(((l2  * l2) - (l1 * l1) + (l3 * l3)) / (2 * l2 * l3))
	
			return planeCF, a1 + math.pi/2, a2 - a1
		end
	end,
	
	generatePoints = function(n, multiplier, coverage_alpha)  -- from Sterpant, "Generating Equidistant Points on a Sphere" devforum
		local goldenRatio = 1 + math.sqrt(5) / 4
		local angleIncrement = math.pi * 2 * goldenRatio
	
		local points = {}

		for i = 0, n do
			local distance = (i * coverage_alpha) / n
			local incline = math.acos(1 - 2 * distance)
			local azimuth = angleIncrement * i
	
			local x = math.sin(incline) * math.cos(azimuth) * multiplier
			local y = math.sin(incline) * math.sin(azimuth) * multiplier
			local z = math.cos(incline) * multiplier
	
			points[i] = Vector3.new(x, y, z)
		end

		return points
	end,
}



return module
