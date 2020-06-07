
include( "shared.lua" )
include( "hp_config.lua" )
include( "hp_maps.lua" )

local MenuColor = Color( 49, 53, 61, 200 )
local ButtonColor = Color( 230, 93, 80, 255 )
local RaceTimer = 0

CreateClientConVar( "HP_AdminKey", KEY_F3, true, false, "Sets the key for the admin menu." )
CreateClientConVar( "HP_TeamKey", KEY_F4, true, false, "Sets the key for the team selection menu." )
CreateClientConVar( "HP_ResetKey", KEY_BACKSLASH, true, false, "Sets the key for vehicle reset." )

hook.Add( "PopulateToolMenu", "HP_KeyMenu", function()
	spawnmenu.AddToolMenuOption( "Options", "Hot Pursuit", "HPKeys", "Controls", "", "", function( panel )
		panel:AddControl( "Header", {
			Description = "Change your Hot Pursuit controls here."
		} )
		panel:AddControl( "Numpad", {
			Label = "Admin Menu Key",
			Command = "HP_AdminKey",
			Label2 = "Team Selection Menu Key",
			Command2 = "HP_TeamKey"
		} )
		panel:AddControl( "Numpad", {
			Label = "Vehicle Reset Key",
			Command = "HP_ResetKey"
		} )
	end )
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

net.Receive( "HPPlayMusic", function( len, ply )
	local randtrack = net.ReadString()
	sound.PlayFile( "sound/"..randtrack, "", function( station )
		if !IsValid( station ) then return end
		station:SetVolume( HP_CONFIG_MUSIC_VOLUME )
	end )
end )

local function OpenTeamMenu( ply )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Select Team" )
	menu:SetSize( 180, 160 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, MenuColor )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	local racerbutton = vgui.Create( "DButton", menu )
	if ply:Team() == TEAM_RACER.ID then
		racerbutton:SetText( "Team Racer (Current)" )
	else
		racerbutton:SetText( "Team Racer" )
	end
	racerbutton:SetTextColor( color_white )
	racerbutton:SetPos( 30, 30 )
	racerbutton:SetSize( 150, 30 )
	racerbutton:CenterHorizontal()
	racerbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ButtonColor )
	end
	racerbutton.DoClick = function()
		net.Start( "ChangeTeam" )
		net.WriteInt( TEAM_RACER.ID, 32 )
		net.SendToServer()
		menu:Close()
		HPNotify( ply, "You have changed your team to Racer." )
	end

	local policebutton = vgui.Create( "DButton", menu )
	if ply:Team() == TEAM_POLICE.ID then
		policebutton:SetText( "Team Police (Current)" )
	else
		policebutton:SetText( "Team Police" )
	end
	policebutton:SetTextColor( color_white )
	policebutton:SetPos( 30, 70 )
	policebutton:SetSize( 150, 30 )
	policebutton:CenterHorizontal()
	policebutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ButtonColor )
	end
	policebutton.DoClick = function()
		net.Start( "ChangeTeam" )
		net.WriteInt( TEAM_POLICE.ID, 32 )
		net.SendToServer()
		menu:Close()
		HPNotify( ply, "You have changed your team to Police." )
	end

	local specbutton = vgui.Create( "DButton", menu )
	if ply:Team() == TEAM_NONE.ID then
		specbutton:SetText( "Team Spectator (Current)" )
	else
		specbutton:SetText( "Team Spectator" )
	end
	specbutton:SetTextColor( color_white )
	specbutton:SetPos( 30, 110 )
	specbutton:SetSize( 150, 30 )
	specbutton:CenterHorizontal()
	specbutton.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, ButtonColor )
	end
	specbutton.DoClick = function()
		net.Start( "ChangeTeam" )
		net.WriteInt( TEAM_NONE.ID, 32 )
		net.SendToServer()
		menu:Close()
		HPNotify( ply, "You have changed your team to Spectator." )
	end
	ply.MenuOpen = true
end

local function OpenAdminMenu( ply )
	local menu = vgui.Create( "DFrame" )
	menu:SetTitle( "Admin Menu" )
	menu:SetSize( ScrW() * 0.5, ScrH() * 0.5 )
	menu:Center()
	menu:MakePopup()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, MenuColor )
	end
	menu.OnClose = function()
		ply.MenuOpen = false
	end
	ply.MenuOpen = true
end

net.Receive( "HP_SyncTimer", function( len, ply )
	local getracetimer = net.ReadInt( 32 )
	local getracename = net.ReadString()
	RaceTimer = getracetimer + CurTime()
	HotPursuitMaps[game.GetMap()] = {} --Looks kinda sloppy but its more efficient than networking the whole table over since the client only needs this one piece of info
	HotPursuitMaps[game.GetMap()][GetGlobalInt( "TrackLayout" )] = {}
	HotPursuitMaps[game.GetMap()][GetGlobalInt( "TrackLayout" )].Name = getracename
end )

net.Receive( "HP_RemoveClientTimer", function()
	RaceTimer = 0
end )

surface.CreateFont( "HPTimer", {
	font = "Arial",
	size = 16,
	weight = 600
} )

local function GetTeamName( ply )
	local team = ply:Team()
	if team == TEAM_RACER.ID then
		return "Racer"
	end
	if team == TEAM_POLICE.ID then
		return "Police"
	end
	return "Spectator"
end

hook.Add( "HUDPaint", "HP_MainHUD", function()
	if GetGlobalBool( "RaceStarted" ) then
		local RaceMode = HP_CONFIG_RACE_MODES[GetGlobalInt( "RaceMode" )].Name
		local TrackType = HP_CONFIG_TRACK_TYPES[GetGlobalInt( "TrackType" )].Name
		local TrackLayout = HotPursuitMaps[game.GetMap()][GetGlobalInt( "TrackLayout" )].Name
		local ply = LocalPlayer()

		draw.RoundedBoxEx( 14, 0, 0, ScrW(), 40, MenuColor, false, false, true, true )
		draw.DrawText( "Race Mode: "..RaceMode, "HPTimer", ScrW() / 2 - 800, 10 )
		draw.DrawText( "Track Type: "..TrackType, "HPTimer", ScrW() / 2 - 400, 10 )
		if RaceTimer - CurTime() <= 0 then
			draw.DrawText( "Race Timer: Disabled", "HPTimer", ScrW() / 2 - 45, 10 )
		else
			draw.DrawText( "Race Timer: "..string.ToMinutesSeconds( RaceTimer - CurTime() ), "HPTimer", ScrW() / 2 - 45, 10 )
		end
		draw.DrawText( "Your Team: "..GetTeamName( ply ), "HPTimer", ScrW() / 2 + 300, 10 )
		draw.DrawText( "Track Layout: "..TrackLayout, "HPTimer", ScrW() / 2 + 600, 10 )
	end
end )

hook.Add( "PlayerButtonDown", "HP_ChangeTeam", function( ply, button )
	if !IsFirstTimePredicted() or ply.MenuOpen then return end
	local teamkey = GetConVar( "HP_TeamKey" ):GetInt()
	local adminkey = GetConVar( "HP_AdminKey" ):GetInt()
	if button == teamkey then
		if GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "You cannot change teams while in a race!" )
			return
		end
		OpenTeamMenu( ply )
	end
	if button == adminkey then
		if !ply:IsAdmin() then
			local teamkeyname = language.GetPhrase( input.GetKeyName( teamkey ) )
			HPNotify( ply, "Only admins can access this menu. If you are looking for the team selection menu, press "..teamkeyname.."." )
			return
		end
		OpenAdminMenu( ply )
	end
end )

hook.Add( "PlayerButtonDown", "HP_ResetVehicle", function( ply, key )
	if IsFirstTimePredicted() and ply:InVehicle() then
		if key == GetConVar( "HP_ResetKey" ):GetInt() then
			if !GetGlobalBool( "RaceStarted" ) then
				HPNotify( ply, "You can only reset your vehicle during a race." )
				return
			end
			if ply.ButtonPressCool and ply.ButtonPressCool > CurTime() then
				HPNotify( ply, "Please wait before resetting your car again." )
				return
			end
			net.Start( "ResetVehicle" )
			net.SendToServer()
			ply.ButtonPressCool = CurTime() + 10
		end
	end
end )

local color_green = Color( 0, 255, 0 )
hook.Add( "PreDrawHalos", "HP_StartLineHalo", function()
	if GetGlobalBool( "PreRace" ) then
		halo.Add( ents.FindByClass( "hp_startline" ), color_green, 1, 1, 3, true, true )
	end
end )

local mat = Material( "icon16/bullet_error.png" )
local function BeaconImage()
	local pl = LocalPlayer()
	local shootPos = pl:GetShootPos()
	local plypos = vector_origin
	local hisPos = pl:GetShootPos()
	if pl:Team() == TEAM_POLICE.ID then
		local pos = hisPos - shootPos
		local unitPos = pos:GetNormalized()
		local trace = util.QuickTrace( shootPos, pos, pl )
		local beacon = ents.FindByClass( "hp_beacon" )[1]
		if !IsValid( beacon ) then return end
		plypos = beacon:GetPos()
		plypos.z = plypos.z + 15
		plypos = plypos:ToScreen()
		surface.SetMaterial( mat )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRect( plypos.x - 16, plypos.y - 74, 40, 40 )
	end
end
hook.Add( "HUDPaint","drawRankIconsHUD", BeaconImage )
