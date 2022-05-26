local Files, Folders, JSON = Ambi.Files, Ambi.Files.Folders, Ambi.Files.JSON
local PLAYER = FindMetaTable( 'Player' ) 

Folders.Create( 'simpleinventory', true )

function PLAYER:SaveItems()
    if not Ambi.SimpleInventory.Config.save_inventory then return end

    local ID = self:SteamID64()

    Files.Create( 'simpleinventory/'..ID..'.json', JSON.In( self.simpleinventory ), true )
end

function PLAYER:LoadItems()
    if not Ambi.SimpleInventory.Config.save_inventory then return end

    local data = Files.Read( 'simpleinventory/'..self:SteamID64()..'.json', 'DATA', true )
    if not data then return end
    
    return JSON.Out( data )
end