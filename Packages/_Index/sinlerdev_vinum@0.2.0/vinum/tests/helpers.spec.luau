local Vinum = require(game.ReplicatedStorage.Vinum)

return {
    ["Vinum.AlwaysTrue should pass updates"] = function(tester)
        local expect = tester.expect

        expect(Vinum.AlwaysTrue()).to.equal(true)
    end,
    ["Vinum.RefuseIfSimilar should dismiss updates when similar"] = function(tester)
        local expect = tester.expect

        expect(Vinum.RefuseIfSimilar(1,1)).to.equal(false)
    end,
    ["Vinum.RefuseIfSimilarAndCleanup should try to clean on acceptence"] = function(tester)
        local expect = tester.expect

        expect(Vinum.RefuseIfSimilarAndCleanup(Instance.new("Part"), Instance.new("Part"))).to.equal(true)
    end
}