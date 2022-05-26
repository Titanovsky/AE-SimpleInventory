Ambi.SimpleInventory.classes = Ambi.SimpleInventory.classes or {}

local Cache, Files = Ambi.Cache, Ambi.Files

-- Main ---------------------------------------------
function Ambi.SimpleInventory.AddClass( sClass, sName, sCategory, sURLIcon, sDescription, fUse )
    if not sClass then return end

    Ambi.SimpleInventory.classes[ tostring( sClass ) ] = {
        name = sName or '',
        desc = sDescription or '',
        category = sCategory or 'Other',
        icon = sURLIcon,
        Use = fUse
    }
end

function Ambi.SimpleInventory.GetClass( sClass )
    return Ambi.SimpleInventory.classes[ sClass or '' ]
end

function Ambi.SimpleInventory.DownloadIcon( sClass )
    local class = Ambi.SimpleInventory.GetClass( sClass )
    if not class and not class.icon then return end

    local file = Files.Read( 'cache/simpleinventory/icons/'..sClass..'.png', 'DATA', true )
    if file then
        local hash = util.CRC( file )
        http.Fetch( class.icon, function( sBody )
            if ( hash == util.CRC( sBody ) ) then return end
        end )
    end

    Cache.CacheURL( 'simpleinventory/icons/'..sClass..'.png', class.icon, 4 )
end

function Ambi.SimpleInventory.DownloadIcons()
    local i = 0
    for class, info in pairs( Ambi.SimpleInventory.classes ) do
        i = i + 0.25

        timer.Simple( i, function() Ambi.SimpleInventory.DownloadIcon( class ) end )
    end
end
concommand.Add( 'ambi_sinv_download_icons', Ambi.SimpleInventory.DownloadIcons )

-- Slots -----------------------------------------------
local PLAYER = FindMetaTable( 'Player' )

function PLAYER:GetSlot( nSlot )
    if not self.simpleinventory then self.simpleinventory = {} return false end
    if not self.simpleinventory[ nSlot ] then return false end

    return self.simpleinventory[ nSlot ]
end

function PLAYER:GetSlots()
    local slots = 0
    for k, v in ipairs( self:GetItems() ) do
        slots = slots + 1
    end
    
    return slots
end

function PLAYER:IsFreeSlot( nSlot )
    if not self.simpleinventory then self.simpleinventory = {} end

    local slot = self:GetSlot( nSlot or 1 )
    if not slot then return false end
    if slot.class then return false end

    return true
end

function PLAYER:GetLastFreeSlot()
    if not self.simpleinventory then self.simpleinventory = {} end

    local items = self:GetItems()
    for slot, item in ipairs( items ) do
        if not item.class then return tonumber( slot ) end
    end

    return false
end

-- Items -----------------------------------------------
function PLAYER:GetItem( sClass )
    if not self.simpleinventory then self.simpleinventory = {} end

    sClass = sClass or ''
    sClass = string.lower( sClass )

    local items = self:GetItems()
    for slot, item in ipairs( items ) do
        if ( item.class == sClass ) then return item end
    end

    return false
end

function PLAYER:GetItems()
    if not self.simpleinventory then self.simpleinventory = {} end

    return self.simpleinventory
end