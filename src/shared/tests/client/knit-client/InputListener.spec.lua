
return function()
    describe("service check", function()
        it("should exist", function(context)
            expect(context.InputListener).to.be.ok()
        end)

        it("should have connected inputs variable", function(context)
            expect(context.InputListener.connected_inputs).to.be.ok()
        end)

        it("should have all the game controls connected", function(context)
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local shared_folder = ReplicatedStorage:WaitForChild("Shared")
            local game_settings = require(shared_folder:WaitForChild("Settings"))

            for i, _ in game_settings.controls do
                expect(context.InputListener.connected_inputs[i]).to.be.ok()
            end
        end)
    end)

    describe("input rebinding", function()

        it("should be able to bind crouch to Q", function(context)
            context.InputListener:SetControlBinding({
                control_name = "crouch",
                keys = {
                    Enum.KeyCode.Q
                }
            })

            expect(context.InputListener.connected_inputs.crouch[Enum.KeyCode.Q]).to.be.ok()
        end)

        it("should be able to rebind crouch to C", function(context)
            context.InputListener:SetControlBinding({
                control_name = "crouch",
                keys = {
                    Enum.KeyCode.C
                }
            })

            expect(context.InputListener.connected_inputs.crouch[Enum.KeyCode.C]).to.be.ok()
        end)

        it("should not be able to rebind a fake control", function(context)
            context.InputListener:SetControlBinding({
                control_name = "fakeControl",
                keys = {
                    Enum.KeyCode.F
                }
            })

            expect(context.InputListener.connected_inputs.fakeControl).never.to.be.ok()
        end)
    end)
end