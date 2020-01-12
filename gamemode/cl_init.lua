
include( "shared.lua" )
include( "hp_maps.lua" )
include( "hp_config.lua" )

hook.Add( "SpawnMenuOpen", "HPSpawnMenu", function()
	local ply = LocalPlayer()
	return ply:IsSuperAdmin()
end )

local function HPNotify( ply, text )
	local textcolor1 = Color( 0, 0, 180, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Hot Pursuit]: ", textcolor2, text )
end
net.Receive( "HPNotify", function( len, ply )
	local text = net.ReadString()
	HPNotify( ply, text )
end )

local function HPNotifyAll( text )
	local textcolor1 = Color( 0, 0, 180, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Hot Pursuit]: ", textcolor2, text )
end
net.Receive( "HPNotifyAll", function( len, ply )
	local text = net.ReadString()
	HPNotifyAll( text )
end )

net.Receive( "HPPlaySound", function( len, ply )
	local sound = net.ReadString()
	surface.PlaySound( sound )
end )

local function OpenTeamMenu( ply )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Select Team" )
	menu:SetSize( 180, 120 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_MENU_COLOR )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local restrictbutton = vgui.Create( "DButton", menu )
	restrictbutton:SetText( "Team Racer" )
	restrictbutton:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictbutton:SetPos( 30, 30 )
	restrictbutton:SetSize( 150, 30 )
	restrictbutton:CenterHorizontal()
	restrictbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictbutton.DoClick = function()
		net.Start( "ChangeTeam" )
		net.WriteString( tostring( TEAM_RACER.ID ) )
		net.SendToServer()
		menu:Close()
		HPNotify( ply, "You have changed your team to Racer." )
	end
	local restrictremove = vgui.Create( "DButton", menu )
	restrictremove:SetText( "Team Police" )
	restrictremove:SetTextColor( DOOR_CONFIG_BUTTON_TEXT_COLOR )
	restrictremove:SetPos( 30, 70 )
	restrictremove:SetSize( 150, 30 )
	restrictremove:CenterHorizontal()
	restrictremove.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, DOOR_CONFIG_BUTTON_COLOR )
	end
	restrictremove.DoClick = function()
		net.Start( "ChangeTeam" )
		net.WriteString( tostring( TEAM_POLICE.ID ) )
		net.SendToServer()
		menu:Close()
		HPNotify( ply, "You have changed your team to Police." )
	end
	ply.MenuOpen = true
end

hook.Add( "PlayerButtonDown", "DoorButtons", function( ply, button )
	local f4 = KEY_F4
	if !IsFirstTimePredicted() or ply.MenuOpen then return end
	if button == f4 then
		if GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "You cannot change teams while in a race!" )
			return
		end
		OpenTeamMenu( ply )
	end
end )