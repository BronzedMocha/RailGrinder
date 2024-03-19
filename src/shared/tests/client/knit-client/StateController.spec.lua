return function()

    describe("action data", function()
        it("verify state_handler_modules", function(context)
            
            --expect(true).to.equal(true)
            expect(context.StateController).to.be.ok()
            expect(context.StateController.state_handler_modules).to.be.ok()

            for _, v in context.StateController.state_handler_modules do
                expect(v).to.be.ok()
                expect(v).never.to.equal({})
            end
        end)
    end)
    describe("state data", function()
        it("verify current_state", function(context)

            --expect(true).to.equal(true)
            expect(context.StateController.client_data.current_state).to.be.a("string")
        end)
    end)
end