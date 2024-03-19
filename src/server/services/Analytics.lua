local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages:WaitForChild("Knit"))

local Analytics = Knit.CreateService {
    Name = "Analytics";
    Client = {};
}

function Analytics:KnitInit()
    self.version_major = 0
    self.version_minor = 1
    self.version_patch = 0

    --self.analytics_module = require(wally:WaitForChild("GameAnalytics"))
    --self.analytics_module:configureBuild(tostring(version_major).."."..tostring(version_minor).."."..tostring(version_patch))

    --self.analytics_module:initServer("GAME_KEY", "SECRET_KEY")
end


return Analytics