net.Receive( 'ambi_simpleinventory_send_client', function()
    local entity, inventory = net.ReadEntity(), net.ReadTable()

    entity.simpleinventory = {}
    entity.simpleinventory = inventory
end )