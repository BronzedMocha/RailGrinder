return function()

    describe("action data", function()
        it("should verify version_major as a number", function(context)
            
            --expect(true).to.equal(true)
            expect(context.Analytics.version_major).to.be.a("number")
        end)
        it("should verify version_minor as a number", function(context)
            
            --expect(true).to.equal(true)
            expect(context.Analytics.version_minor).to.be.a("number")
        end)
        it("should verify version_patch as a number", function(context)
            
            --expect(true).to.equal(true)
            expect(context.Analytics.version_patch).to.be.a("number")
        end)
    end)
end