return function()
    beforeAll(function(context)
        print("running beforeAll- server")
        local ServerScriptService = game:GetService("ServerScriptService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local packages = ReplicatedStorage:WaitForChild("Packages")
        local knit_module = packages:WaitForChild("Knit")
        local Knit = require(knit_module)

        --[[local knit_services_loaded_by_module = knit_module:GetAttribute("LoadedServices")
        if not knit_services_loaded_by_module then
            knit_module:GetAttributeChangedSignal("LoadedServices"):Wait()
        end]]

        Knit.OnStart():await()
        -- setup knit services in context table
        print("beforeAll: after knit.OnStart, adding services to context")
        for i, v in Knit:GetServices() do
            context[i] = v
        end

        print("beforeAll: done")
    end)
end