return function()
    beforeAll(function(context)
        print("running beforeAll")
        local player = game.Players.LocalPlayer
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local packages = ReplicatedStorage:WaitForChild("Packages")
        local Knit = require(packages:WaitForChild("Knit"))
        
        -- waits for knit to get called from the client init script

        Knit.OnStart():await()
        -- setup knit controllers in context table
        print("beforeAll: after knit.OnStart, adding controllers to context")
        for i, v in Knit:GetControllers() do
            context[i] = v
        end

        print("beforeAll: done")
    end)
end