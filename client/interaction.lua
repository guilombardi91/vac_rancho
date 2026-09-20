RuralInteraction = {}

function RuralInteraction.createListingPoint(listing)
    lib.points.new({ coords = vec3(listing.x, listing.y, listing.z), distance = 12, listing = listing,
        nearby = function(point)
            DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.55, 0.55, 0.35, 110, 80, 35, 150, false, false, 2, false, nil, nil, false)
            if point.currentDistance < 2.0 then
                lib.showTextUI(('[E] Consultar %s — $%.2f'):format(listing.label, listing.price))
                if IsControlJustReleased(0, 0xCEFD9220) then TriggerEvent('rural_system:client:openListing', listing) end
            end
        end,
        onExit = function() lib.hideTextUI() end,
    })
end
