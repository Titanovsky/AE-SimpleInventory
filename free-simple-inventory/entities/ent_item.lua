local Ents, NW, C = Ambi.RegEntity, Ambi.NW, Ambi.General.Global.Colors
local ENT = {}

ENT.Class       = 'sinv_item'
ENT.Type	    = 'anim'

ENT.PrintName	= 'Item'
ENT.Author		= 'Ambi'
ENT.Category	= 'SimpleInventory [GitHub]'
ENT.Spawnable   = false

ENT.Stats = {
    type = 'Entity',
    model = Ambi.SimpleInventory.Config.model_item,
    module = 'SimpleInventory [GitHub]',
    date = '26.05.2021 07:35'
}

Ents.Register( ENT.Class, 'ents', ENT )

if CLIENT then
    ENT.RenderGroup = RENDERGROUP_BOTH

    function ENT:DrawTranslucent()
        self:DrawShadow( false )

        if ( LocalPlayer():GetPos():Distance( self:GetPos() ) > 400 ) then return end
        Ents.Draw( self, false )
    end
    
    return Ents.Register( ENT.Class, 'ents', ENT )
end 

function ENT:Initialize()
    Ents.Initialize( self, self.Stats.model )
    Ents.Physics( self, nil, nil, COLLISION_GROUP_WEAPON, true, true )

    self:SetTrigger()
end

function ENT:SetHeader( sHeader )
    NW.SetString( self, 'Header', tostring( sHeader ) )
end

function ENT:SetCount( nCount )
    NW.SetInt( self, 'Count', nCount or 1 )
end

function ENT:GetCount()
    return NW.GetInt( self, 'Count' )
end

function ENT:SetClass( sClass )
    NW.SetString( self, 'Class', sClass or '' )
end

function ENT:GetClass( sClass )
    return NW.GetString( self, 'Class' )
end

function ENT:SetItem( sClass, nCount )
    local class = Ambi.SimpleInventory.GetClass( sClass or '' )
    if not class then return end

    self:SetHeader( class.name )
    self:SetCount( nCount )
    self:SetClass( sClass )
    self.class = sClass
end

function ENT:Use( eCaller )
    if not self.class then return end
    if timer.Exists( 'AmbiSimpleInventoryDropItem:'..tostring( self ) ) then timer.Remove( 'AmbiSimpleInventoryDropItem:'..tostring( self ) ) end

    hook.Call( '[Ambi.SimpleInventory.TakeItem]', nil, eCaller, self.class, self:GetCount(), self )

    local inv_count = eCaller:GetItem( self.class ) and eCaller:GetItem( self.class ).count or 0 
    if not eCaller:GetLastFreeSlot() and ( inv_count == 0 ) then return end

    local ent_count = self:GetCount()
    local max = Ambi.SimpleInventory.Config.max_count_item
    local result = inv_count + ent_count

    if ( result > max ) then
        local remains = result - max

        self:SetCount( remains )
        eCaller:AddItem( self.class, max, true )
    else
        self:Remove()
        eCaller:AddItem( self.class, ent_count, true )
    end
end

Ents.Register( ENT.Class, 'ents', ENT )