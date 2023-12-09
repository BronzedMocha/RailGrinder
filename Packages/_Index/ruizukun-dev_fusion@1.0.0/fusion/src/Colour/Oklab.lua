local Oklab = {}

function Oklab.to(rgb)
	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005
	local lRoot = l ^ 0.3333333333333333
	local mRoot = m ^ 0.3333333333333333
	local sRoot = s ^ 0.3333333333333333

	return Vector3.new(
		lRoot * 0.2104542553 + mRoot * 0.793617785 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.428592205 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.808675766
	)
end
function Oklab.from(lab, unclamped)
	local lRoot = lab.X + lab.Y * 0.3963377774 + lab.Z * 0.2158037573
	local mRoot = lab.X - lab.Y * 0.1055613458 - lab.Z * 0.0638541728
	local sRoot = lab.X - lab.Y * 0.0894841775 - lab.Z * 1.291485548
	local l = lRoot ^ 3
	local m = mRoot ^ 3
	local s = sRoot ^ 3
	local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local blue = l * -4.196086299999999E-3 - m * 0.7034186147 + s * 1.707614701

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

return Oklab
