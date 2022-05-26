local C, SND, GUI, Draw, A, Files, Cache = Ambi.General.Global.Colors, Ambi.General.Global.Sounds, Ambi.UI.GUI, Ambi.UI.Draw, Ambi.General, Ambi.Files, Ambi.Cache
local w, h = ScrW(), ScrH()
local occupaited_slots = 0

local COLOR_PANEL = Color( 0, 0, 0, 240 )

Files.Folders.Create( 'cache/simpleinventory/icons/', true )

local function GetOccupaitedSlots()
    occupaited_slots = 0 
    
    for slot, item in ipairs( LocalPlayer():GetItems() ) do
        if item.class then occupaited_slots = occupaited_slots + 1 end
    end
end

local function Drop( sClass, nCount )
    net.Start( 'ambi_simpleinventory_drop_item' )
        net.WriteString( sClass )
        net.WriteUInt( nCount, 16 )
    net.SendToServer()
end

local function ParsItems( vguiScrollPanel )
    if not ValidPanel( vguiScrollPanel ) then return end
    
    vguiScrollPanel:Clear()
    GetOccupaitedSlots()

    local items = LocalPlayer():GetItems()
    for slot, item in ipairs( items ) do
        if not item.class then continue end

        Ambi.SimpleInventory.DownloadIcon( item.class )
        local icon = Material( '../data/ambi/cache/simpleinventory/icons/'..item.class..'.png' )

        local name = Ambi.SimpleInventory.classes[ item.class ].name
        local old_count = item.count
        local panel = GUI.DrawPanel( vguiScrollPanel, vguiScrollPanel:GetWide(), 68, 0, ( 68 + 4 ) * ( slot - 1 ), function( self, w, h )
            Draw.Box( w, h, 0, 0, COLOR_PANEL )

            Draw.Text( 72, h / 2, name..' x'..tostring( item.count ), '24 Arial', C.ABS_WHITE, 'center-left' )
            if not icon:IsError() then Draw.Material( 64, 64, 4, 4, icon ) end
            
            -- For Refresh ----------------------------------
            local refresh_item = LocalPlayer():GetItem( item.class )
            if not refresh_item or ( item.count ~= refresh_item.count ) then ParsItems( vguiScrollPanel ) return end
        end )

        local drop = GUI.DrawButton( panel, 70, 25, panel:GetWide() - 70 - 26, 32, nil, nil, nil, function( self )
            local menu = vgui.Create( 'DMenu', self )
            menu.Paint = function( self, w, h ) Draw.Box( w, h, 0, 0, COLOR_PANEL ) end

            local drop_x = menu:AddOption( 'Выкинуть X', function() 
                local frame = GUI.DrawFrame( nil, 240, 240, w / 2 - 240 / 2, h / 2 - 240 / 2, '', true, true, true, function( self, w, h )
                    Draw.Box( w, h, 0, 0, COLOR_PANEL )
                    Draw.Text( w / 2, 4, 'x'..item.count, '22 Arial', C.ABS_WHITE, 'top-center' )
                end )

                local count = GUI.DrawTextEntry( frame, frame:GetWide() - 8, 30, 4, frame:GetTall() / 2 - 15, '28 Arial', C.AMBI_BLACK, nil, nil, 'Введите сюда нужное количество', false, true )

                local drop = GUI.DrawButton( frame, 70, 25, frame:GetWide() / 2 - 70 / 2, frame:GetTall() - 25 - 4, nil, nil, nil, function( self )
                    local count = tonumber( count:GetValue() )
                    timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )

                    if not count then return end
                    if ( count <= 0 ) then return end
                    if ( count > item.count ) then return end

                    Drop( item.class, count )
                    frame:Remove()
                end, function( self, w, h )
                    Draw.Box( w, h, 0, 0, COLOR_PANEL )
                    Draw.Text( w / 2, h / 2, 'Выкинуть', '16 Arial', C.ABS_WHITE, 'center' )
                end )
            end )
            drop_x:SetFont( '20 Ambi' )
            drop_x:SetTextColor( C.ABS_WHITE )

            if ( item.count > 2 ) then
                local drop_one = menu:AddOption( 'Выкинуть 1', function() 
                    Drop( item.class, 1 )
                    timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
                end )
                drop_one:SetFont( '20 Ambi' )
                drop_one:SetTextColor( C.ABS_WHITE )
            end

            local half = math.floor( item.count / 2 )
            if ( half > 0 ) then
                local drop_half = menu:AddOption( 'Выкинуть '..half, function()
                    Drop( item.class, half )
                    timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
                end )
                drop_half:SetFont( '20 Ambi' )
                drop_half:SetTextColor( C.ABS_WHITE )
            end

            local drop_all = menu:AddOption( 'Выкинуть '..item.count, function() 
                Drop( item.class, item.count )
                timer.Simple( 0.1, function() ParsItems( vguiScrollPanel ) end )
            end )
            drop_all:SetFont( '20 Ambi' )
            drop_all:SetTextColor( C.ABS_WHITE )

            menu:SetPos( 0, 0 )
            menu:Open()
        end, function( self, w, h )
            Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
            Draw.Text( w / 2, h / 2, 'Выкинуть', '16 Arial', C.ABS_WHITE, 'center' )
        end )

        if Ambi.SimpleInventory.classes[ item.class ].Use then
            local use = GUI.DrawButton( panel, 85, 25, panel:GetWide() - 85 - 26, 4, nil, nil, nil, function( self )
                net.Start( 'ambi_simpleinventory_use_item' )
                    net.WriteString( item.class )
                net.SendToServer()

                timer.Simple( 0.1, function()
                    if ( item.count == 1 ) and not LocalPlayer():GetItem( item.class ) then
                        ParsItems( vguiScrollPanel )
                    elseif ( item.count > 1 ) and ( LocalPlayer():GetItem( item.class ).count ~= item.count ) then
                        item.count = item.count - 1
                    end
                end )
            end, function( self, w, h )
                Draw.Box( w, h, 0, 0, C.AMBI_PANEL )
                Draw.Text( w / 2, h / 2, 'Использовать', '16 Arial', C.AMBI_GREEN, 'center' )
            end )
        end
    end
end

function Ambi.SimpleInventory.ShowInventory( vguiParent )
    if ( hook.Call( '[Ambi.SimpleInventory.CanOpenInventory]' ) == false ) then return end
    if not LocalPlayer():Alive() then return end

    local inventory = GUI.DrawScrollPanel( vguiParent, vguiParent:GetWide(), vguiParent:GetTall(), 0, 0 )
    ParsItems( inventory )

    inventory.OnRemove = function( self )
        hook.Call( '[Ambi.SimpleInventory.RemoveInventory]', nil, self )
    end

    return inventory
end

A.AddConsoleCommand( 'sinv_open_inventory', function()
    if ( hook.Call( '[Ambi.SimpleInventory.CanOpenInventory]' ) == false ) then return end
    GetOccupaitedSlots()

    local background = GUI.DrawFrame( nil, w / 1.4, h / 1.4, 0, 0, '', true, true, true, function( self, w, h ) 
        Draw.Box( w, h, 0, 0, COLOR_PANEL )
        Draw.Text( 4, 1, occupaited_slots..'/'..LocalPlayer():GetSlots(), '24 Arial', C.ABS_WHITE, nil, 1, C.ABS_BLACK )
    end )
    background:Center()
    background.OnKeyCodePressed = function( self, nKey )
        if ( nKey == KEY_I ) then background:Remove() end
    end

    local inv = GUI.DrawPanel( background, background:GetWide() - 8, background:GetTall() - 24 - 4, 4, 24, function() end )
    Ambi.SimpleInventory.ShowInventory( inv )
end )