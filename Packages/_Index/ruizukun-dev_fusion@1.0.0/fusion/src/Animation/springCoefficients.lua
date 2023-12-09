local function springCoefficients(time, damping, speed)
	if time == 0 or speed == 0 then
		return 1, 0, 0, 1
	end

	local posPos, posVel, velPos, velVel

	if damping > 1 then
		local scaledTime = time * speed
		local alpha = math.sqrt(damping ^ 2 - 1)
		local scaledInvAlpha = -0.5 / alpha
		local z1 = -alpha - damping
		local z2 = 1 / z1
		local expZ1 = math.exp(scaledTime * z1)
		local expZ2 = math.exp(scaledTime * z2)

		posPos = (expZ2 * z1 - expZ1 * z2) * scaledInvAlpha
		posVel = (expZ1 - expZ2) * scaledInvAlpha / speed
		velPos = (expZ2 - expZ1) * scaledInvAlpha * speed
		velVel = (expZ1 * z1 - expZ2 * z2) * scaledInvAlpha
	elseif damping == 1 then
		local scaledTime = time * speed
		local expTerm = math.exp(-scaledTime)

		posPos = expTerm * (1 + scaledTime)
		posVel = expTerm * time
		velPos = expTerm * (-scaledTime * speed)
		velVel = expTerm * (1 - scaledTime)
	else
		local alpha = math.sqrt(1 - damping ^ 2)
		local invAlpha = 1 / alpha
		local alphaTime = alpha * time
		local expTerm = math.exp(-time * damping * speed)
		local sinTerm = expTerm * math.sin(alphaTime)
		local cosTerm = expTerm * math.cos(alphaTime)
		local sinInvAlpha = sinTerm * invAlpha
		local sinInvAlphaDamp = sinInvAlpha * damping

		posPos = sinInvAlphaDamp + cosTerm
		posVel = sinInvAlpha / speed
		velPos = (sinInvAlphaDamp * damping + sinTerm * alpha) * -speed
		velVel = cosTerm - sinInvAlphaDamp
	end

	return posPos, posVel, velPos, velVel
end

return springCoefficients
