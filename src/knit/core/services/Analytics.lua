local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local wally = packages:WaitForChild("wally")
local Knit = require(wally:WaitForChild("Knit"))

local Analytics = Knit.CreateService {
    Name = "Analytics";
    Client = {};
}

function Analytics:KnitInit()
    local version_major = 0
    local version_minor = 1
    local version_patch = 0

    --self.analytics_module = require(wally:WaitForChild("GameAnalytics"))
    --self.analytics_module:configureBuild(tostring(version_major).."."..tostring(version_minor).."."..tostring(version_patch))

    --self.analytics_module:initServer("GAME_KEY", "SECRET_KEY")
end


return Analytics