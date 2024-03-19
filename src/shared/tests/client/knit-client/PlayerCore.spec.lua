return function()

    describe("character instances", function()
        it("should find the player", function(context)
            expect(context.PlayerCore.player).to.be.ok()
        end)

        it("should find the character", function(context)
            expect(context.PlayerCore.character).to.be.ok()
        end)

        it("should find the humanoid", function(context)
            expect(context.PlayerCore.humanoid).to.be.ok()
        end)

        it("should find the root", function(context)
            expect(context.PlayerCore.root).to.be.ok()
        end)

        it("should find the players measurements", function(context)
            expect(context.PlayerCore.measurements).to.be.a("table")
        end)
    end)
end