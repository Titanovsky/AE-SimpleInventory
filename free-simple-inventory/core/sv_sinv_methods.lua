local UT, C = Ambi.General.Utility, Ambi.General.Global.Colors
local Player = FindMetaTable( 'Player' )

-- Slots -----------------------------------------------
function Player:SetSlots( nSlot )
    if not self.simpleinventory then self.simpleinventory = {} end

    nSlot = nSlot or 1
    nSlot = math.floor( nSlot )
    if ( nSlot < 0 ) then self.simpleinventory = {} return end

    local len = #self:GetItems()
    if ( len == nSlot ) then return end

    if ( nSlot > len ) then
        for i = len + 1, nSlot do
            self.simpleinventory[ i ] = {}
            self.simpleinventory[ i ].slot = i
        end
    elseif ( nSlot < len ) then
        for i = ( len + nSlot ) - len + 1, len do
            self.simpleinventory[ i ] = nil
        end
    end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.SetSlots]', nil, self, nSlot, self.simpleinventory )
end

function Player:AddSlots( nSlot )
    if not self.simpleinventory then self:SetSlot( Ambi.SimpleInventory.Config.start_slots ) end

    nSlot = nSlot or 1
    nSlot = math.floor( nSlot )
    
    local len = #self:GetItems()
    if ( nSlot > 0 ) then
        for i = len + 1, len + nSlot do
            self.simpleinventory[ i ] = {}
            self.simpleinventory[ i ].slot = i
        end
    elseif ( nSlot < 0 ) then
        for i = len + nSlot + 1, len do
            self.simpleinventory[ i ] = nil
        end 
    end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.AddSlots]', nil, self, nSlot, self.simpleinventory )
end

-- Items -----------------------------------------------
function Player:SetItem( nSlot, sClass, nCount, bMax )
    if not self.simpleinventory then self:SetSlot( Ambi.SimpleInventory.Config.start_slots ) end
    if not self.simpleinventory[ nSlot ] then return end

    sClass = sClass or ''
    sClass = string.lower( sClass )

    nCount = nCount or 1
    nCount = math.floor( nCount )
    
    local class = Ambi.SimpleInventory.classes[ sClass or '' ]
    if not class then return end

    local item = self:GetItem( sClass )
    if ( nCount <= 0 ) then self:RemoveItem( sClass ) return end
    if bMax then
        if ( nCount > Ambi.SimpleInventory.Config.max_count_item ) then nCount = Ambi.SimpleInventory.Config.max_count_item  end
    end

    self.simpleinventory[ nSlot ] = {}
    self.simpleinventory[ nSlot ].class = sClass
    self.simpleinventory[ nSlot ].slot = nSlot
    self.simpleinventory[ nSlot ].count = nCount

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.SetItem]', nil, self, nSlot, sClass, nCount, bMax, self.simpleinventory )
end

local function DropItemOnNoFreeSlot( ePly, sClass, nCount )
    local pos, ang = UT.GetFrontPos( ePly, 44 ), ePly:EyeAngles()
    local ent = ents.Create( 'sinv_item' )
    ent:SetPos( pos )
    ent:SetAngles( ang )
    ent:Spawn()
    ent:SetHeader( Ambi.SimpleInventory.GetClass( sClass ).name )
    ent:SetItem( sClass, nCount )
    if FPP then ent:CPPISetOwner( ePly )
    else ent:SetOwnerPlayer( ePly )
    end
end

function Player:AddItem( sClass, nCount, bMax, bDropOnNoFreeSlot )
    if not self.simpleinventory then self.simpleinventory = {} end

    sClass = sClass or ''
    sClass = string.lower( sClass )

    nCount = nCount or 0
    nCount = math.floor( nCount )
    if ( nCount == 0 ) then return end

    local class = Ambi.SimpleInventory.classes[ sClass ]
    if not class then return end
    
    local item = self:GetItem( sClass )
    local slot = item and item.slot or nil
    local count = item and item.count or nil
    local old_count = count
    if not item then 
        local free_slot = self:GetLastFreeSlot() 
        if not free_slot then 
            if bDropOnNoFreeSlot then DropItemOnNoFreeSlot( self, sClass, nCount ) end
            
            return 
        end

        slot = free_slot
        count = 0
        self.simpleinventory[ free_slot ] = { slot = free_slot, class = sClass, count = 0 }
    end

    count = nCount + count
    if bMax then
        local max = Ambi.SimpleInventory.Config.max_count_item
        if ( count >= Ambi.SimpleInventory.Config.max_count_item ) then count = Ambi.SimpleInventory.Config.max_count_item end
    end

    self.simpleinventory[ slot ].count = count
    if ( self.simpleinventory[ slot ].count <= 0 ) then self:RemoveItem( sClass ) end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.AddItem]', nil, self, sClass, count, bMax, self.simpleinventory, old_count )
end

function Player:RemoveItem( sClass )
    if not self.simpleinventory then self.simpleinventory = {} return end

    sClass = sClass or ''
    sClass = string.lower( sClass )

    local item = self:GetItem( sClass )
    if not item then return end

    local current_slot = item.slot
    self.simpleinventory[ current_slot ] = { slot = current_slot }

    for slot, item in ipairs( self.simpleinventory ) do
        if ( slot <= current_slot ) then continue end
        if not item.class then continue end

        self.simpleinventory[ slot - 1 ] = self.simpleinventory[ slot ]
        self.simpleinventory[ slot - 1 ].slot = slot - 1

        self.simpleinventory[ slot ] = { slot = slot }
    end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.RemoveItem]', nil, self, sClass, self.simpleinventory )
end

function Player:RemoveItems()
    if not self.simpleinventory then self.simpleinventory = {} return end

    for slot, item in pairs( self.simpleinventory ) do
        self.simpleinventory[ slot ] = {}
    end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.RemoveItems]', nil, self, self.simpleinventory )
end

-- Specific --------------------------------------------
function Player:DropItem( sClass, nCount )
    local item = self:GetItem( sClass or '' )
    if not item then return end

    local count = math.floor( nCount )
    if ( count <= 0 ) then return end
    if ( item.count < count ) then return end

    local pos, ang = UT.GetFrontPos( self, 44 ), self:EyeAngles()
    local ent = ents.Create( 'sinv_item' )
    ent:SetPos( pos )
    ent:SetAngles( ang )
    ent:Spawn()
    ent:SetHeader( Ambi.SimpleInventory.GetClass( sClass ).name )
    ent:SetItem( sClass, count )
    if ent.SetOwnerPlayer then ent:SetOwnerPlayer( self ) end

    if ( count == item.count ) then self:RemoveItem( sClass ) 
    else
        item.count = item.count - count
        Ambi.SimpleInventory.SendClient( self )
    end

    timer.Create( 'AmbiSimpleInventoryDropItem:'..tostring( ent ), 60 * 6, 1, function()
        if IsValid( ent ) then ent:Remove() end
    end )

    if not self.warning_on_remove_items then
        self.warning_on_remove_items = true
        self:ChatPrint( 'Если спустя 6 минут никто не подберёт мешок, он исчезнет!' )
    end

    self:SaveItems()
    hook.Call( '[Ambi.SimpleInventory.DropItem]', nil, self, sClass, ent )
end

function Player:UseItem( sClass )
    local item = self:GetItem( sClass or '' )
    if not item then return end

    local class = Ambi.SimpleInventory.GetClass( sClass )
    if not class or not class.Use then return end

    local use = class.Use( self )
    if not use then return end

    if ( item.count == 1 ) then
        self:RemoveItem( sClass )
    elseif ( item.count > 1 ) then
        item.count = item.count - 1
    end

    self:SaveItems()

    Ambi.SimpleInventory.SendClient( self )
    hook.Call( '[Ambi.SimpleInventory.UseItem]', nil, self, sClass )
end