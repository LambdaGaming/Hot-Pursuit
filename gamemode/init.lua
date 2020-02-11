
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "hp_config.lua" )

include( "shared.lua" )
include( "hp_maps.lua" )
include( "hp_config.lua" )

RacerTable = {}
FinishedPly = {}

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

function GM:PlayerSpawnSWEP( ply, class )
	if ply:IsSuperAdmin() then return true end
	return false
end

function GM:PlayerSpawnVehicle( ply, model )
	if GetGlobalBool( "RaceStarted" ) then
		HPNotify( "You cannot spawn vehicles during a race." )
		return false
	end
	if HP_CONFIG_BLACKLIST and HP_CONFIG_BLACKLIST[model] then
		HPNotify( ply, "This vehicle is blacklisted." )
		return false
	end
	if ply:Team() == TEAM_NONE.ID then
		HPNotify( ply, "Pick a team by pressing F4 before spawning a vehicle." )
		return false
	end
	return true
end

function GM:CanExitVehicle( veh, ply )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 then return false end
	return true
end

function ChangeTeam( ply, team )
	ply:StripWeapons()
	ply:SetTeam( team.ID )
	ply:SetModel( table.Random( team.Playermodel ) )
	hook.Run( "PlayerLoadout", ply )
end

util.AddNetworkString( "ChangeTeam" )
net.Receive( "ChangeTeam", function( len, ply )
	local id = net.ReadInt( 32 )
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

function PreRace( type )
	SetGlobalBool( "PreRace", true )
	local mapconfig = HotPursuitMaps[game.GetMap()][type]
	local e = ents.Create( "hp_startline" )
	e:SetPos( mapconfig.StartPos.Pos )
	e:SetAngles( mapconfig.StartPos.Ang )
	e:Spawn()
	HPNotifyAll( "The pre-race has started. Racers, get to the starting line, which is outlined in green, and wait for the race to begin." )
	HPNotifyAll( "Cops, hide along the track and wait for racers to pass you." )
end

util.AddNetworkString( "HPPlayMusic" )
function StartRace( type, timelimit )
	local mapconfig = HotPursuitMaps[game.GetMap()][type]
	for k,v in pairs( player.GetAll() ) do
		if !v:InVehicle() then
			HPNotifyAll( "Attempted to start a race but not all players are in their vehicles!" )
			return
		end
		
		local veh = v:GetVehicle()
		if v:Team() == TEAM_POLICE.ID then
			veh:Fire( "TurnOff" )
			--[[ for a,b in RandomPairs( mapconfig.PoliceSpawns ) do
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
			end ]]
		end
		if v:Team() == TEAM_RACER.ID then
			veh:Fire( "TurnOff" )
			--[[ for a,b in RandomPairs( mapconfig.CarSpawns ) do
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
			end ]]
		end
		if v:Team() == TEAM_NONE.ID then
			HPNotify( v, "You are a spectator of this race since you didn't pick a team." )
			if IsValid( veh ) then veh:Remove() end
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
			if timelimit or GetGlobalBool( "TrackType" ) == 2 or mapconfig.FreeRoamOnly then
				timer.Create( "RaceTimer", HP_CONFIG_RACE_TIMER, 1, function() EndRace( false, true ) end )
			end
			timer.Create( "DisqualifyTimer", 15, 1, function()
				for k,v in pairs( player.GetAll() ) do
					if v:Team() == TEAM_RACER.ID and !table.HasValue( RacerTable, v ) then
						Disqualify( v, "Failed to cross start line within 15 seconds of the race starting." )
					end
				end
			end )
			SetGlobalBool( "PreRace", false )
			SetGlobalBool( "RaceStarted", true )
			SyncTimer( nil, true )
		end
	end )

	HPNotifyAll( "The race will begin soon!" )
	
	if !GetGlobalBool( "PreRace" ) then
		local e = ents.Create( "hp_startline" )
		e:SetPos( mapconfig.StartPos.Pos )
		e:SetAngles( mapconfig.StartPos.Ang )
		e:Spawn()
	end

	if GetGlobalInt( "TrackType" ) == 1 then
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
	end
	net.Start( "HPPlayMusic" )
	net.WriteString( table.Random( HP_CONFIG_MUSIC_LIST ) )
	net.Broadcast()
end

function SyncTimer( ply, all )
	net.Start( "HP_SyncTimer" )
	if timer.Exists( "RaceTimer" ) then
		net.WriteInt( timer.TimeLeft( "RaceTimer" ), 32 )
	else
		net.WriteInt( 0, 32 )
	end
	if all then
		net.Broadcast()
	else
		net.Send( ply )
	end
end

util.AddNetworkString( "HP_SyncTimer" )
hook.Add( "PlayerInitialSpawn", "HP_SyncTimer", function( ply )
	SyncTimer( ply )
end )

util.AddNetworkString( "HP_RemoveClientTimer" )
function RemoveClientTimer()
	net.Start( "HP_RemoveClientTimer" )
	net.Broadcast()
end

local function GetWinners( normal )
	local winners = ""
	if normal then
		if !FinishedPly[1] then return "None" end
		return FinishedPly[1]:Nick()
	end
	for k,v in pairs( RacerTable ) do
		if k >= 2 then
			winners = winners..", "..v:Nick()
		else
			winners = winners..v:Nick()
		end
	end
	return winners
end

function EndRace( forced, timed )
	for k,v in pairs( ents.GetAll() ) do
		local removedents = {
			["hp_finishline"] = true,
			["hp_startline"] = true,
			["automod_spikestrip"] = true,
			["hp_barrier"] = true
		}
		if v:IsVehicle() then v.Finished = false end
		if removedents[v:GetClass()] then v:Remove() end
		if v:IsPlayer() then
			v.Finished = false
			v:GodDisable()
			v:ConCommand( "stopsound" )
		end
	end
	SetGlobalBool( "PreRace", false )
	SetGlobalBool( "RaceStarted", false )

	if forced then
		HPNotifyAll( "The race was ended by a superadmin. Nobody wins." )
	end
	if timed then
		if GetGlobalInt( "TrackType" ) == 2 then
			HPNotifyAll( "Time's up! Winners of the free-roam race: "..GetWinners() )
		else
			HPNotifyAll( "Time's up! Winner of the race: "..GetWinners( true ) )
		end
	end
	
	timer.Remove( "RaceTimer" )
	timer.Remove( "DisqualifyTimer" )
	RemoveClientTimer()
	FinishedPly = {}
end

function Disqualify( ply, reason )
	ChangeTeam( ply, TEAM_NONE )
	HPNotifyAll( ply:Nick().." has been disqualified from the race! Reason: "..reason )
	table.RemoveByValue( RacerTable, ply )
	if #RacerTable == 0 then
		EndRace()
		HPNotifyAll( "The last player in the race has been disqualified. Nobody wins." )
	end
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
			HPNotify( ply, "The track layout you selected doesn't exist." )
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
	if split[1] == "!prestart" then
		if !ply:IsSuperAdmin() then
			HPNotify( ply, "Only superadmins can use this command!" )
			return ""
		end
		if GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "A race has already started!" )
			return ""
		end
		if !HotPursuitMaps[game.GetMap()][tonumber( split[2] )] then
			HPNotify( ply, "The track layout you selected doesn't exist." )
			return ""
		end
		PreRace( tonumber( split[2] ) )
		return ""
	end
	if split[1] == "!tracktype" then
		if !ply:IsSuperAdmin() then
			HPNotify( ply, "Only superadmins can use this command!" )
			return ""
		end
		if !HotPursuitMaps[game.GetMap()][tonumber( split[2] )] then
			HPNotify( ply, "The track type you selected doesn't exist." )
			return ""
		end
		SetGlobalBool( "TrackType", tonumber( split[2] ) )

		local tracktype = HP_CONFIG_TRACK_TYPES[tonumber(split[2])]
		HPNotifyAll( "The track type has been changed to "..tracktype.Name..". "..tracktype.Description )
		return ""
	end
end )

hook.Add( "PlayerLeaveVehicle", "HP_LeaveDisqualify", function( ply, veh )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 and ply:Team() != TEAM_NONE.ID then
		Disqualify( ply, "Leaving vehicle during race." )
	end
end )

hook.Add( "AM_OnTakeDamage", "HP_AutomodDamage", function( veh, dam ) --Automod damage support
	if GetGlobalBool( "RaceStarted" ) then
		local driver = veh:GetDriver()
		if IsValid( driver ) and driver:Team() != TEAM_NONE.ID then
			local health = veh:GetNWInt( "AM_VehicleHealth" )
			if health <= 0 then
				Disqualify( driver, "Vehicle was destroyed." )
			end
		end
	end
end )

hook.Add( "VC_engineExploded", "HP_VCModDamage", function( veh ) --VCMod damage support
	if GetGlobalBool( "RaceStarted" ) then
		local driver = veh:GetDriver()
		if IsValid( driver ) and driver:Team() != TEAM_NONE.ID then
			Disqualify( driver, "Vehicle was destroyed." )
		end
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