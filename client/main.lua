CreateThread(function()
    for _, listing in ipairs(Config.RanchListings) do
        RuralInteraction.createListingPoint(listing)
        RuralAnimals.createPasturePoint(listing)
        RuralVeterinary.createPoint(listing)
    end
end)
