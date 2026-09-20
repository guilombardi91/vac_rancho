RegisterNetEvent('rural_system:client:openListing', function(listing)
    lib.registerContext({ id = 'rural_listing_' .. listing.key, title = listing.label, options = {
        { title = ('Preço: $%.2f'):format(listing.price), description = ('Tipo: %s | Região: %s'):format(Config.RanchTypes[listing.type].label, listing.region), readOnly = true },
        { title = 'Comprar propriedade', icon = 'handshake', onSelect = function()
            local confirmation = lib.alertDialog({ header = 'Confirmar compra', content = ('Deseja adquirir **%s** por **$%.2f**?'):format(listing.label, listing.price), centered = true, cancel = true })
            if confirmation == 'confirm' then TriggerServerEvent('rural_system:server:purchaseListing', listing.key) end
        end },
    } })
    lib.showContext('rural_listing_' .. listing.key)
end)
