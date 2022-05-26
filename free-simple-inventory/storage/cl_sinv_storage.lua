local C, GUI, Draw, Cache = Ambi.General.Global.Colors, Ambi.UI.GUI, Ambi.UI.Draw, Ambi.Cache
local W, H = ScrW(), ScrH()

Ambi.SimpleInventory.storage_items = {} or Ambi.SimpleInventory.storage_items
Ambi.SimpleInventory.slots = 0 or Ambi.SimpleInventory.slots
Ambi.SimpleInventory.storage = nil or Ambi.SimpleInventory.storage
local occupaited_slots = 0

local function Action( bTake, sClass, nSlot, nCount )
    if bTake then
        net.Start( 'ambi_sinv_storage_take' )
            net.WriteUInt( nCount, 20 )
            net.WriteUInt( nSlot, 20 )
            net.WriteEntity( Ambi.SimpleInventory.storage )
        net.SendToServer()
    else -- Give
        local item = LocalPlayer():GetItem( sClass )
        if not item then return end
        if ( item.count < nCount ) then return end

        net.Start( 'ambi_sinv_storage_give' )
            net.WriteUInt( nCount, 20 )
            net.WriteUInt( nSlot, 20 )
            net.WriteString( sClass )
            net.WriteEntity( Ambi.SimpleInventory.storage )
        net.SendToServer()
    end
end

local function ParsItems( vguiScrollPanel )
    vguiScrollPanel:Clear()
    occupaited_slots = 0

    for i = 1, Ambi.SimpleInventory.slots do
        local slot = GUI.DrawPanel( vguiScrollPanel, vguiScrollPanel:GetWide(), 68, 0, ( 68 + 4 ) * ( i - 1 ), function( self, w, h )
            Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
        end )

        local item = Ambi.SimpleInventory.storage_items[ i ]
        if item.empty then 
            local give = GUI.DrawButton( slot, 70, 25, slot:GetWide() / 2 - 70 / 2, slot:GetTall() / 2 - 25 / 2, nil, nil, nil, function( self )
                local menu = vgui.Create( 'DMenu', self )
                menu.Paint = function( self, w, h ) Draw.Box( w, h, 0, 0, C.AMBI_PANEL ) end

                for slot, item in ipairs( LocalPlayer():GetItems() ) do
                    if not item.class then continue end
                    
                    local name = Ambi.SimpleInventory.GetClass( item.class ).name

                    local give_x = menu:AddOption( name..' x'..item.count, function() 
                        local frame = GUI.DrawFrame( nil, 240, 240, W / 2 - 240 / 2, H / 2 - 240 / 2, '', true, true, true, function( self, w, h )
                            Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                            Draw.Text( w / 2, 4, name..' x'..item.count, '22 Arial', C.ABS_WHITE, 'top-center' )
                        end )

                        local count = GUI.DrawTextEntry( frame, frame:GetWide() - 8, 30, 4, frame:GetTall() / 2 - 15, '28 Arial', C.AMBI_BLACK, nil, nil, 'Введите сюда нужное количество', false, true )

                        local drop = GUI.DrawButton( frame, 70, 25, frame:GetWide() / 2 - 70 / 2, frame:GetTall() - 25 - 4, nil, nil, nil, function( self )
                            local count = tonumber( count:GetValue() )
                            timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )

                            if not count then return end
                            if ( count <= 0 ) then return end
                            if ( count > item.count ) then return end

                            Action( false, item.class, i, count )
                            frame:Remove()
                        end, function( self, w, h )
                            Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                            Draw.Text( w / 2, h / 2, 'Положить', '16 Arial', C.AMBI_GREEN, 'center' )
                        end )
                    end )
                    give_x:SetFont( '14 Ambi' )
                    give_x:SetTextColor( C.ABS_WHITE )
                end

                menu:SetPos( 0, 0 )
                menu:Open()
            end, function( self, w, h )
                Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                Draw.Text( w / 2, h / 2, '+', '24 Arial', C.AMBI_GREEN, 'center' )
            end )

            continue 
        end

        occupaited_slots = occupaited_slots + 1

        if not item.class then continue end
        local name = Ambi.SimpleInventory.GetClass( item.class ).name

        Ambi.SimpleInventory.DownloadIcon( item.class )
        local icon = Material( '../data/ambi/cache/simpleinventory/icons/'..item.class..'.png' )
        
        local panel = GUI.DrawPanel( vguiScrollPanel, vguiScrollPanel:GetWide(), 68, 0, ( 68 + 4 ) * ( i - 1 ), function( self, w, h )
            --Draw.Box( w, h, 0, 0, C.AMB_PANEL )

            Draw.Text( 72, h / 2, name..' x'..tostring( item.count ), '24 Arial', C.ABS_WHITE, 'center-left' )
            if not icon:IsError() then Draw.Material( 64, 64, 4, 4, icon ) end
        end )

        if LocalPlayer():GetItem( item.class ) or LocalPlayer():GetLastFreeSlot() then
            local take = GUI.DrawButton( panel, 70, 25, panel:GetWide() - 70 - 26, 32, nil, nil, nil, function( self )
                local menu = vgui.Create( 'DMenu', self )
                menu.Paint = function( self, w, h ) Draw.Box( w, h, 0, 0, C.AMB_PANEL ) end

                local drop_x = menu:AddOption( 'Взять X', function() 
                    local frame = GUI.DrawFrame( nil, 240, 240, W / 2 - 240 / 2, H / 2 - 240 / 2, '', true, true, true, function( self, w, h )
                        Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                        Draw.Text( w / 2, 4, 'x'..item.count, '22 Arial', C.ABS_WHITE, 'top-center' )
                    end )

                    local count = GUI.DrawTextEntry( frame, frame:GetWide() - 8, 30, 4, frame:GetTall() / 2 - 15, '28 Arial', C.AMBI_BLACK, nil, nil, 'Введите сюда нужное количество', false, true )

                    local drop = GUI.DrawButton( frame, 70, 25, frame:GetWide() / 2 - 70 / 2, frame:GetTall() - 25 - 4, nil, nil, nil, function( self )
                        local count = tonumber( count:GetValue() )
                        timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )

                        if not count then return end
                        if ( count <= 0 ) then return end
                        if ( count > item.count ) then return end

                        Action( true, nil, i, count )
                        frame:Remove()
                    end, function( self, w, h )
                        Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                        Draw.Text( w / 2, h / 2, 'Взять', '16 Arial', C.ABS_WHITE, 'center' )
                    end )
                end )
                drop_x:SetFont( '20 Ambi' )
                drop_x:SetTextColor( C.ABS_WHITE )

                if ( item.count > 2 ) then
                    local drop_one = menu:AddOption( 'Взять 1', function() 
                        Action( true, nil, i, 1 )
                        timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
                    end )
                    drop_one:SetFont( '20 Ambi' )
                    drop_one:SetTextColor( C.ABS_WHITE )
                end

                local half = math.floor( item.count / 2 )
                if ( half > 0 ) then
                    local drop_half = menu:AddOption( 'Взять '..half, function()
                        Action( true, nil, i, half )
                        timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
                    end )
                    drop_half:SetFont( '20 Ambi' )
                    drop_half:SetTextColor( C.ABS_WHITE )
                end

                local drop_all = menu:AddOption( 'Взять Всё', function() 
                    Action( true, nil, i, item.count )
                    timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
                end )
                drop_all:SetFont( '20 Ambi' )
                drop_all:SetTextColor( C.ABS_WHITE )

                menu:SetPos( 0, 0 )
                menu:Open()
            end, function( self, w, h )
                Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                Draw.Text( w / 2, h / 2, 'Взять', '16 Arial', C.ABS_WHITE, 'center' )
            end )
        end

        if not LocalPlayer():GetItem( item.class ) then continue end

        local name = Ambi.SimpleInventory.GetClass( item.class ).name
        local count = LocalPlayer():GetItem( item.class ).count or 0
        local refill = GUI.DrawButton( panel, 70, 25, panel:GetWide() - 70 - 26, 6, nil, nil, nil, function( self )
            local menu = vgui.Create( 'DMenu', self )
            menu.Paint = function( self, w, h ) Draw.Box( w, h, 0, 0, C.AMB_PANEL ) end

            local drop_x = menu:AddOption( 'Пополнить X', function() 
                local frame = GUI.DrawFrame( nil, 240, 240, W / 2 - 240 / 2, H / 2 - 240 / 2, '', true, true, true, function( self, w, h )
                    Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                    Draw.Text( w / 2, 4, tostring( name )..' x'..count, '22 Arial', C.ABS_WHITE, 'top-center' )
                end )

                local count = GUI.DrawTextEntry( frame, frame:GetWide() - 8, 30, 4, frame:GetTall() / 2 - 15, '28 Arial', C.AMBI_BLACK, nil, nil, 'Введите сюда нужное количество', false, true )

                local drop = GUI.DrawButton( frame, 70, 25, frame:GetWide() / 2 - 70 / 2, frame:GetTall() - 25 - 4, nil, nil, nil, function( self )
                    local count = tonumber( count:GetValue() )
                    timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )

                    if not count then return end
                    if ( count <= 0 ) then return end

                    Action( false, item.class, i, count )
                    frame:Remove()
                end, function( self, w, h )
                    Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                    Draw.Text( w / 2, h / 2, 'Пополнить', '16 Arial', C.ABS_WHITE, 'center' )
                end )
            end )
            drop_x:SetFont( '20 Ambi' )
            drop_x:SetTextColor( C.ABS_WHITE )

            menu:SetPos( 0, 0 )
            menu:Open()
        end, function( self, w, h )
            Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
            Draw.Text( w / 2, h / 2, 'Пополнить', '16 Arial', C.ABS_WHITE, 'center' )
        end )
    end
end

function Ambi.SimpleInventory.ShowStorage( vguiParent )
    if not LocalPlayer():Alive() then return end

    local storage = GUI.DrawScrollPanel( vguiParent, vguiParent:GetWide(), vguiParent:GetTall() - 22, 0, 22, function( self, w, h )
        --Draw.Box( w, h, 0, 0, C.AMB_PANEL )
    end )
    ParsItems( storage )

    return storage
end

net.Receive( 'ambi_sinv_storage_get_items', function()
    Ambi.SimpleInventory.storage_items = net.ReadTable() or {}
    Ambi.SimpleInventory.slots = net.ReadUInt( 20 ) or 0
    Ambi.SimpleInventory.storage = net.ReadEntity()
end )

net.Receive( 'ambi_sinv_storage_open', function()
    local window = GUI.DrawFrame( nil, W / 2, H / 2, 0, 0, '', true, true, true, function( self, w, h ) 
        Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
        Draw.Text( 2, 2, occupaited_slots..'/'..Ambi.SimpleInventory.slots, '26 Oswald Light', C.ABS_WHITE )
    end )
    window:Center()

    window.OnRemove = function()
        net.Start( 'ambi_sinv_storage_close')
            net.WriteEntity( Ambi.SimpleInventory.storage )
        net.SendToServer()

        occupaited_slots = 0
    end

    window.Think = function( self )
        if not LocalPlayer():Alive() then self:Remove() return end
        if not IsValid( Ambi.SimpleInventory.storage ) then self:Remove() return end
    end

    Ambi.SimpleInventory.ShowStorage( window )
end )