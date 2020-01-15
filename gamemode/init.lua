
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "hp_maps.lua" )
include( "hp_config.lua" )

function GM:PlayerLoadout( ply )
	return true
end

function GM:PlayerSpawnNPC()
	return false
end

function GM:PlayerSpawnObject( ply )
	if ply:IsSuperAdmin() then return true end
	return false
end

function GM:PlayerSpawnSENT( ply, class )
	if ply:IsSuperAdmin() or HP_CONFIG_VEHICLE_CLASSES[class] then return true end
	return false
end

function GM:PlayerSpawnSWEP()
	if ply:IsSuperAdmin() then return true end
	return false
end

function GM:PlayerSpawnVehicle( ply, model )
	if HP_CONFIG_BLACKLIST and HP_CONFIG_BLACKLIST[model] then return false end
	return true
end

function GM:CanExitVehicle( veh, ply )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 then return false end
	return true
end

function ChangeTeam( ply, team, respawn )
	ply:StripWeapons()
	ply:SetTeam( team.ID )
	ply:SetModel( table.Random( team.Playermodel ) )
	hook.Run( "PlayerLoadout", ply )
	if respawn then
		ply:Spawn()
	end
end

util.AddNetworkString( "ChangeTeam" )
net.Receive( "ChangeTeam", function( len, ply )
	local id = tonumber( net.ReadString() )
	local team
	if id == 1 then
		team = TEAM_NONE
	elseif id == 2 then
		team = TEAM_RACER
	else
		team = TEAM_POLICE
	end
	ChangeTeam( ply, team )
end )

function GM:PlayerInitialSpawn( ply )
	ChangeTeam( ply, TEAM_NONE )
end

util.AddNetworkString( "HPNotify" )
function HPNotify( ply, text )
	net.Start( "HPNotify" )
	net.WriteString( text )
	net.Send( ply )
end

util.AddNetworkString( "HPNotifyAll" )
function HPNotifyAll( text )
	net.Start( "HPNotifyAll" )
	net.WriteString( text )
	net.Broadcast()
end

util.AddNetworkString( "HPPlaySound" )
function HPPlaySound( ply, sound, broadcast )
	if broadcast then
		net.Start( "HPPlaySound" )
		net.WriteString( sound )
		net.Broadcast()
		return
	end
	net.Start( "HPPlaySound" )
	net.WriteString( sound )
	net.Send( ply )
end

function StartRace( type, timelimit )
	local mapconfig = HotPursuitMaps[game.GetMap()][type]
	for k,v in pairs( player.GetAll() ) do
		if !v:InVehicle() then
			HPNotifyAll( "Attempted to start a race but not all players are in their vehicles!" )
			return
		end
		
		if v:Team() == TEAM_POLICE.ID then
			for a,b in RandomPairs( mapconfig.PoliceSpawns ) do
				local veh = v:GetVehicle()
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
				veh:Fire( "TurnOff" )
			end
		elseif v:Team() == TEAM_RACER.ID then
			for a,b in RandomPairs( mapconfig.CarSpawns ) do
				local veh = v:GetVehicle()
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
				veh:Fire( "TurnOff" )
			end
		else
			HPNotify( v, "You are a spectator of this race since you didn't pick a team." )
		end

		if GetGlobalInt( "RaceMode" ) == 1 then
			v:GodEnable() --Players don't need to take damage if they can't get out of their cars
		end
	end

	local countdown = HP_CONFIG_PRERACE_TIMER
	SetGlobalBool( "RaceCountdown", true )
	timer.Create( "RaceCountdown", 1, HP_CONFIG_PRERACE_TIMER + 1, function()
		if countdown > 0 then
			HPNotifyAll( tostring( countdown ) ) --Will eventually be converted to a HUD element
			HPPlaySound( nil, "buttons/blip1.wav", true )
			countdown = countdown - 1
		else
			HPNotifyAll( "GO!" )
			HPPlaySound( nil, "plats/elevbell1.wav", true )
			for k,v in pairs( player.GetAll() ) do
				if IsValid( v ) and v:InVehicle() then
					local veh = v:GetVehicle()
					veh:Fire( "TurnOn" )
				end
			end
			SetGlobalBool( "RaceCountdown", false )
		end
	end )

	HPNotifyAll( "The race will begin soon!" )

	if timelimit then
		timer.Create( "RaceTimer", HP_CONFIG_RACE_TIMER, 1, function() EndRace() end )
	end
	
	local e = ents.Create( "hp_finishline" )
	e:SetPos( mapconfig.FinishPos.Pos )
	e:SetAngles( mapconfig.FinishPos.Ang )
	e:Spawn()

	for k,v in ipairs( mapconfig.BlockSpawns ) do
		local e = ents.Create( "hp_barrier" )
		e:SetPos( v[1] )
		e:SetAngles( v[2] )
		e:Spawn()
	end
	SetGlobalBool( "RaceStarted", true )
end

function EndRace( forced )
	for k,v in pairs( ents.GetAll() ) do
		local removedents = {
			["hp_finishline"] = true,
			["automod_spikestrip"] = true,
			["hp_barrier"] = true
		}
		if v:IsVehicle() then v.Finished = false end
		if removedents[v:GetClass()] then v:Remove() end
		if v:IsPlayer() then
			v.Finished = false
			if GetGlobalInt( "RaceMode" ) == 1 then
				v:GodDisable()
			end
		end
	end
	SetGlobalBool( "RaceStarted", false )
	if forced then HPNotifyAll( "The race was ended by a superadmin. Nobody wins." ) end
	timer.Remove( "RaceTimer" )
end

function Disqualify( ply, reason )
	ChangeTeam( ply, TEAM_NONE, true )
	HPNotifyAll( ply:Nick().." has been disqualified from the race! Reason: "..reason )
end

util.AddNetworkString( "ResetVehicle" )
local function ResetVehicle( len, ply )
	if IsValid( ply ) and ply:InVehicle() then
		local reset = ply.VehResetPos
		local veh = ply:GetVehicle()
		if reset then
			veh:SetPos( reset.Pos )
			veh:SetAngles( reset.Ang )
			veh:SetRenderFX( kRenderFxStrobeFaster )
			timer.Simple( 3, function() veh:SetRenderFX( kRenderFxNone ) end )
			HPNotify( ply, "Successfully reset your vehicle." )
		else
			HPNotify( ply, "There is no place for you to reset to." )
		end
	end
end
net.Receive( "ResetVehicle", ResetVehicle )

hook.Add( "PlayerSay", "HP_StartRaceCommand", function( ply, text )
	local split = string.Split( text, " " )
	if split[1] == "!start" then
		if !ply:IsSuperAdmin() then
			HPNotify( ply, "Only superadmins can use this command!" )
			return ""
		end
		if GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "A race has already started!" )
			return ""
		end
		if !HotPursuitMaps[game.GetMap()][tonumber( split[2] )] then
			HPNotify( ply, "The track type you selected doesn't exist." )
			return ""
		end
		if tobool( split[3] ) then
			StartRace( tonumber( split[2] ), true )
		else
			StartRace( tonumber( split[2] ) )
		end
		return ""
	end
	if split[1] == "!end" then
		if !ply:IsSuperAdmin() then
			HPNotify( ply, "Only superadmins can use this command!" )
			return ""
		end
		if !GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "There is no race to end!" )
			return ""
		end
		EndRace( true )
		return ""
	end
end )

hook.Add( "PlayerLeaveVehicle", "HP_LeaveDisqualify", function( ply, veh )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 then
		Disqualify( ply, "Leaving vehicle during race." )
	end
end )

local function SaveVehPosAng( ply )
	local veh = ply:GetVehicle()
	local vehpos = veh:GetPos()
	local vehang = veh:GetAngles()
	ply.VehResetPos = {}
	ply.VehResetPos.Pos = vehpos
	ply.VehResetPos.Ang = vehang
end

hook.Add( "Think", "HP_CarTracker", function()
	if !GetGlobalBool( "RaceStarted" ) then return end
	for k,v in pairs( player.GetAll() ) do
		if v.TrackerCooldown and v.TrackerCooldown > CurTime() then return end
		if IsValid( v ) and v:InVehicle() then
			if v:Team() == TEAM_RACER.ID or v:Team() == TEAM_POLICE.ID then
				SaveVehPosAng( v )
				v.TrackerCooldown = CurTime() + 3
			end
		end
	end
end )

hook.Add( "InitPostEntity", "HP_VersionCheck", function()
	local version
	local color_blue = Color( 0, 0, 255 )
	http.Fetch( "https://raw.githubusercontent.com/LambdaGaming/Hot-Pursuit/master/version.txt",
		function( body, len, headers, code )
			version = tonumber( body )
		end,
		function( error )
			MsgC( color_blue, "\nWarning: Hot Pursuit version check failed to load. Either Github is down or you don't have internet.\n" )
			return
		end
	)
	if !isnumber( version ) then
		MsgC( color_blue, "\nWarning: Hot Pursuit version check failed to load. Either Github is down or OP screwed up again.\n" )
		return
	end
	if HP_VERSION < version then
		MsgC( color_blue, "\nWarning: Hot Pursuit is out of date! Please update through the workshop or Github.\n" )
		return
	end
	MsgC( color_blue, "\nHot Pursuit version "..version.." successfully loaded.\n" )
end )