hook.Add( 'PlayerInitialSpawn', 'Ambi.SimpleInventory.SetInventory', function( ePly )
    timer.Simple( 1, function()
        if not IsValid( ePly ) then return end
        
        ePly.simpleinventory = {}

        if not Ambi.SimpleInventory.Config.save_inventory then ePly:SetSlots( Ambi.SimpleInventory.Config.start_slots ) return end

        local inventory = ePly:LoadItems()
        if not inventory then ePly:SetSlots( Ambi.SimpleInventory.Config.start_slots ) return end

        local slots = #inventory
        ePly:SetSlots( slots )

        for slot, item in ipairs( inventory ) do
            ePly.simpleinventory[ slot ] = item
        end

        ePly:SaveItems()
        Ambi.SimpleInventory.SendClient( ePly )
    end )
end )