local send_client = net.AddString( 'ambi_simpleinventory_send_client' )
function Ambi.SimpleInventory.SendClient( ePly, eReceiver )
    if not IsValid( ePly ) or not ePly.simpleinventory then return end

    net.Start( send_client )
        net.WriteEntity( ePly )
        net.WriteTable( ePly.simpleinventory )
    net.Send( eReceiver or ePly )
end

local drop_item = net.AddString( 'ambi_simpleinventory_drop_item' )
net.Receive( drop_item, function( _, ePly )
    if not IsValid( ePly ) then return end
    
    local class = net.ReadString() or ''
    local item = ePly:GetItem( class )
    if not item then return end

    local count = net.ReadUInt( 16 ) or 1
    if ( item.count < count ) then return end

    ePly:DropItem( class, count )
end )

local use_item = net.AddString( 'ambi_simpleinventory_use_item')
net.Receive( use_item, function( _, ePly )
    if not IsValid( ePly ) then return end
    
    local class = net.ReadString() or ''
    local item = ePly:GetItem( class )
    if not item then return end
    if not Ambi.SimpleInventory.classes[ class ].Use then return end

    local use = ePly:UseItem( class )
end )