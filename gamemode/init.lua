
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "hp_config.lua" )
AddCSLuaFile( "hp_maps.lua" )

include( "shared.lua" )
include( "hp_maps.lua" )
include( "hp_config.lua" )

RacerTable = {}
CopTable = {}
FinishedPly = {}
CompletedRaces = 0

function GM:PlayerLoadout( ply )
	local DefaultWeapons = {
		"weapon_physgun",
		"gmod_camera",
		"gmod_tool"
	}
	for k,v in pairs( DefaultWeapons ) do
		ply:Give( v )
	end
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

function GM:PhysgunPickup( ply, ent )
	if ply:IsSuperAdmin() then return true end
	if HP_CONFIG_VEHICLE_CLASSES[ent:GetClass()] and ent.VehOwner and ent.VehOwner == ply then
		return true
	end
	return false
end

function GM:PlayerSetModel( ply )
	if ply:Team() == TEAM_RACER.ID then
		ply:SetModel( table.Random( TEAM_RACER.Playermodel ) )
	elseif ply:Team() == TEAM_POLICE.ID then
		ply:SetModel( table.Random( TEAM_POLICE.Playermodel ) )
	end
end

function GM:CanDrive( ply, ent )
	return false
end

function GM:CanTool( ply, tr, tool )
	if ply:IsSuperAdmin() then return true end
	local allowed = {
		["colour"] = true,
		["material"] = true,
		["trails"] = true
	}
	if HP_CONFIG_VEHICLE_CLASSES[tr.Entity:GetClass()] and tr.Entity.VehOwner and tr.Entity.VehOwner == ply and allowed[tool] then
		return true
	end
	return false
end

function GM:PlayerSpawnedVehicle( ply, ent )
	if HP_CONFIG_VEHICLE_CLASSES[ent:GetClass()] then
		ent.VehOwner = ply
	end
end

function GM:PlayerSpawnVehicle( ply, model )
	if GetGlobalBool( "RaceStarted" ) then
		HPNotify( ply, "You cannot spawn vehicles during a race." )
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
	if GetGlobalBool( "RaceCountdown" ) then return false end
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 then return false end
	return true
end

function ChangeTeam( ply, team )
	if !IsValid( ply ) then return end
	ply:SetTeam( team.ID )
	ply:SetModel( table.Random( team.Playermodel ) )
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
	if !HotPursuitMaps[game.GetMap()] then return end
	SetGlobalBool( "PreRace", true )
	local mapconfig = HotPursuitMaps[game.GetMap()][type]
	if GetGlobalInt( "TrackType" ) == 3 then
		local e = ents.Create( "hp_startline" )
		e:SetPos( mapconfig.FinishPos.Pos )
		e:SetAngles( mapconfig.FinishPos.Ang )
		e:Spawn()
	else
		local e = ents.Create( "hp_startline" )
		e:SetPos( mapconfig.StartPos.Pos )
		e:SetAngles( mapconfig.StartPos.Ang )
		e:Spawn()
	end
	HPNotifyAll( "The pre-race has started. Racers, get to the starting line, which is outlined in green, and wait for the race to begin." )
	HPNotifyAll( "Cops, hide along the track and wait for racers to pass you." )
end

util.AddNetworkString( "HPPlayMusic" )
function StartRace( type, timelimit )
	local maptable = HotPursuitMaps[game.GetMap()] or {}
	local mapconfig = maptable[type] or {}
	local racemode = GetGlobalInt( "RaceMode" )
	for k,v in pairs( player.GetAll() ) do
		if v:Team() != TEAM_NONE.ID and !v:InVehicle() then
			HPNotifyAll( "Attempted to start a race but not all players are in their vehicles!" )
			return
		end
		
		local veh = v:GetVehicle()
		if v:Team() == TEAM_NONE.ID then
			HPNotify( v, "You are a spectator of this race since you didn't pick a team." )
			if IsValid( veh ) then veh:Remove() end
		else
			if veh.fphysSeat then
				local parent = veh.base
				parent:StopEngine()
			else
				veh:Fire( "TurnOff" )
			end
		end

		if GetGlobalInt( "RaceMode" ) == 1 then
			v:GodEnable() --Players don't need to take damage if they can't get out of their cars
		end
	end
	HPNotifyAll( "Race Mode: "..HP_CONFIG_RACE_MODES[racemode].Name )
	HPNotifyAll( "Mode Description: "..HP_CONFIG_RACE_MODES[racemode].Description )

	local countdown = HP_CONFIG_PRERACE_TIMER
	SetGlobalBool( "RaceCountdown", true )
	timer.Create( "RaceCountdown", 1, HP_CONFIG_PRERACE_TIMER + 1, function()
		if countdown > 0 then
			HPNotifyAll( tostring( countdown ) )
			HPPlaySound( nil, "buttons/blip1.wav", true )
			countdown = countdown - 1
		else
			HPNotifyAll( "GO!" )
			HPPlaySound( nil, "plats/elevbell1.wav", true )
			for k,v in pairs( player.GetAll() ) do
				if IsValid( v ) and v:InVehicle() then
					local veh = v:GetVehicle()
					local racemode = GetGlobalInt( "RaceMode" )
					if veh.fphysSeat then
						local parent = veh.base
						parent:StartEngine()
					else
						veh:Fire( "TurnOn" )
					end
					v:StripWeapons()

					local modetable = HP_CONFIG_RACE_MODES[racemode]
					if racemode == 3 then
						if v:Team() != TEAM_NONE.ID then
							v:Give( table.Random( HP_CONFIG_PISTOLS ) )
						end
					end
					if racemode == 4 then
						if v:Team() != TEAM_NONE.ID then
							v:Give( table.Random( HP_CONFIG_RIFLES ) )
						end
					end

					if v:Team() == TEAM_POLICE.ID then
						table.insert( CopTable, v )
						if GetConVar( "AM_Config_TirePopEnabled" ):GetBool() and modetable.UseSpikestrip then --Automod support, VCMod support will come once I have a way to make sure the addon is mounted
							v:Give( "weapon_spikestrip" )
						end
						if modetable.UseBeacons then
							v:Give( "weapon_hp_beacon" )
						end
						if modetable.UseMines then
							v:Give( "weapon_hp_mine" )
						end
					end
				end
			end
			SetGlobalBool( "RaceCountdown", false )
			if timelimit or GetGlobalBool( "TrackType" ) == 2 then
				timer.Create( "RaceTimer", HP_CONFIG_RACE_TIMER, 1, function() EndRace( false, true ) end )
			end
			if GetGlobalBool( "TrackType" ) != 2 then
				timer.Create( "DisqualifyTimer", 15, 1, function()
					for k,v in pairs( player.GetAll() ) do
						if v:Team() == TEAM_RACER.ID and !table.HasValue( RacerTable, v ) then
							Disqualify( v, "Failed to cross start line within 15 seconds of the race starting." )
						end
					end
				end )
			end
			SetGlobalBool( "PreRace", false )
			SetGlobalBool( "RaceStarted", true )
			SyncTimer( nil, true )
		end
	end )

	HPNotifyAll( "The race will begin soon!" )
	
	if !GetGlobalBool( "PreRace" ) then
		if GetGlobalInt( "TrackType" ) == 3 then
			local e = ents.Create( "hp_startline" )
			e:SetPos( mapconfig.FinishPos.Pos )
			e:SetAngles( mapconfig.FinishPos.Ang )
			e:Spawn()
		elseif GetGlobalInt( "TrackType" ) == 1 then
			local e = ents.Create( "hp_startline" )
			e:SetPos( mapconfig.StartPos.Pos )
			e:SetAngles( mapconfig.StartPos.Ang )
			e:Spawn()
		end
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
	elseif GetGlobalInt( "TrackType" ) == 3 then
		local e = ents.Create( "hp_finishline" )
		e:SetPos( mapconfig.StartPos.Pos )
		e:SetAngles( mapconfig.StartPos.Ang )
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

util.AddNetworkString( "HP_SyncTimer" )
function SyncTimer( ply, all )
	if !HotPursuitMaps or !HotPursuitMaps[game.GetMap()] then return end
	local name = HotPursuitMaps[game.GetMap()][GetGlobalInt( "TrackLayout" )].Name
	net.Start( "HP_SyncTimer" )
	if timer.Exists( "RaceTimer" ) then
		net.WriteInt( timer.TimeLeft( "RaceTimer" ), 32 )
	else
		net.WriteInt( 0, 32 )
	end
	net.WriteString( name )
	if all then
		net.Broadcast()
	else
		net.Send( ply )
	end
end

util.AddNetworkString( "HP_SendMapInfo" )
local function SendMapInfo( ply )
	if !HotPursuitMaps[game.GetMap()] then ReadCurrentMap( true ) end --Check to see if the map info can be read from file
	if !HotPursuitMaps[game.GetMap()] then return end --Check again for the map info and if it doesn't exist, don't send the message
	net.Start( "HP_SendMapInfo" )
	net.WriteTable( HotPursuitMaps[game.GetMap()] )
	net.Send( ply )
end

hook.Add( "PlayerSpawn", "HP_SyncTimer", function( ply )
	SyncTimer( ply )
	SendMapInfo( ply )
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
			["hp_barrier"] = true,
			["hp_mine"] = true
		}
		if v:IsVehicle() then v.Finished = false end
		if removedents[v:GetClass()] then v:Remove() end
		if v:IsPlayer() then
			v.Finished = false
			v:GodDisable()
			v:ConCommand( "stopsound" )
			v:StripWeapons()
			hook.Run( "PlayerLoadout", v )
			v.VehResetPos = {}
		end
	end
	SetGlobalBool( "PreRace", false )
	SetGlobalBool( "RaceStarted", false )

	if forced then
		HPNotifyAll( "The race was ended by an admin. Nobody wins." )
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
	RacerTable = {}
	CopTable = {}
	CompletedRaces = CompletedRaces + 1
	if HP_CONFIG_RACES_UNTIL_MAP_CHANGE > 0 and CompletedRaces >= HP_CONFIG_RACES_UNTIL_MAP_CHANGE then
		HPNotifyAll( "The map will be changed to a random supported map in 10 seconds." )
		timer.Simple( 10, function()
			if HP_CONFIG_ONLY_SUPPORTED_MAPS then
				local supported = {}
				local current = {}
				local currentmaps = file.Find( "maps/*.bsp", "GAME" )
				for k,v in pairs( currentmaps ) do
					v = string.GetFileFromFilename( v )
					v = string.StripExtension( v )
					table.insert( current, v )
				end
				for k,v in pairs( current ) do
					for a,b in pairs( HP_CONFIG_SUPPORTED_MAPS ) do
						if v == b then table.insert( supported, v ) end
					end
				end
				RunConsoleCommand( "changelevel", table.Random( supported ) )
				return
			end
			local current = {}
			local currentmaps = file.Find( "maps/*.bsp", "GAME" )
			for k,v in pairs( currentmaps ) do
				v = string.GetFileFromFilename( v )
				v = string.StripExtension( v )
				table.insert( current, v )
			end
			RunConsoleCommand( "changelevel", table.Random( current ) )
		end )
	end
end

function Disqualify( ply, reason )
	if !IsValid( ply ) then return end
	ChangeTeam( ply, TEAM_NONE )
	HPNotifyAll( ply:Nick().." has been disqualified from the race! Reason: "..reason )
	table.RemoveByValue( RacerTable, ply )
	table.RemoveByValue( CopTable, ply )
	if #RacerTable == 0 then
		EndRace()
		HPNotifyAll( "The last racer has been disqualified. Police win." )
	elseif #CopTable == 0 then
		EndRace()
		HPNotifyAll( "The last cop has been disqualified. Racers win." )
	end
end

util.AddNetworkString( "ResetVehicle" )
local function ResetVehicle( len, ply )
	if IsValid( ply ) and ply:InVehicle() then
		local reset = ply.VehResetPos
		local veh = ply:GetVehicle()
		local vehicle
		if reset and reset.Pos and reset.Ang then
			if veh.fphysSeat then
				vehicle = veh.base
			else
				vehicle = veh
			end
			if vehicle:GetVelocity():Length() > 100 then
				HPNotify( ply, "Please slow down before resetting your vehicle to avoid physics glitches." )
				return
			end
			vehicle:SetPos( reset.Pos )
			vehicle:SetAngles( reset.Ang )
			vehicle:SetRenderFX( kRenderFxStrobeFaster )
			timer.Simple( 3, function()
				if !IsValid( vehicle ) then return end
				vehicle:SetRenderFX( kRenderFxNone )
			end )
			HPNotify( ply, "Successfully reset your vehicle." )
		else
			HPNotify( ply, "There is no place for you to reset to." )
		end
	end
end
net.Receive( "ResetVehicle", ResetVehicle )

util.AddNetworkString( "HP_StartRace" )
local function StartRaceCommand( len, ply )
	local layout = net.ReadInt( 32 )
	local timed = net.ReadBool()
	if !ply:IsAdmin() then --Run these checks server side to avoid exploits
		HPNotify( ply, "Only admins can start races!" )
		return
	end
	if GetGlobalBool( "RaceStarted" ) then
		HPNotify( ply, "A race has already started!" )
		return
	end
	if !HotPursuitMaps[game.GetMap()] then
		ReadCurrentMap()
	end
	StartRace( layout, timed )
end
net.Receive( "HP_StartRace", StartRaceCommand )

util.AddNetworkString( "HP_EndRace" )
local function EndRaceCommand( len, ply )
	if !ply:IsAdmin() then
		HPNotify( ply, "Only admins can end races!" )
	end
	if !GetGlobalBool( "RaceStarted" ) then
		HPNotify( ply, "There is no race to end!" )
		return
	end
	EndRace( true )
end
net.Receive( "HP_EndRace", EndRaceCommand )

util.AddNetworkString( "HP_PreStartRace" )
local function PreStartCommand( len, ply )
	local layout = net.ReadInt( 32 )
	if !ply:IsAdmin() then
		HPNotify( ply, "Only admins can start the pre-race!" )
		return
	end
	if GetGlobalBool( "RaceStarted" ) then
		HPNotify( ply, "A race has already started!" )
		return
	end
	PreRace( layout )
end
net.Receive( "HP_PreStartRace", PreStartCommand )

util.AddNetworkString( "HP_SetTrackType" )
local function TrackTypeCommand( len, ply )
	local tracktype = net.ReadInt( 32 )
	local typeinfo = HP_CONFIG_TRACK_TYPES[tracktype]
	SetGlobalBool( "TrackType", tracktype )
	HPNotifyAll( "The track type has been changed to "..typeinfo.Name..". "..typeinfo.Description )
end
net.Receive( "HP_SetTrackType" , TrackTypeCommand )

util.AddNetworkString( "HP_SetRaceMode" )
local function RaceModeCommand( len, ply )
	local mode = net.ReadInt( 32 )
	local modename = HP_CONFIG_RACE_MODES[mode]
	if !ply:IsAdmin() then
		HPNotify( ply, "Only admins can change the race mode!" )
		return
	end
	if !HotPursuitMaps[game.GetMap()] then
		ReadCurrentMap()
	end
	SetGlobalBool( "RaceMode", mode )
	HPNotifyAll( "The race mode has been changed to "..modename.Name..". "..modename.Description )
end
net.Receive( "HP_SetRaceMode", RaceModeCommand )

hook.Add( "PlayerLeaveVehicle", "HP_LeaveDisqualify", function( ply, veh )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 and ply:Team() != TEAM_NONE.ID then
		Disqualify( ply, "Leaving vehicle during race." )
	end
end )

hook.Add( "PlayerDeath", "HP_DeathDisqualify", function( victim, inflictor, attacker )
	if GetGlobalBool( "RaceStarted" ) or GetGlobalBool( "RaceCountdown" ) then
		if victim:Team() == TEAM_RACER.ID then
			Disqualify( victim, "Died in the race." )
			table.RemoveByValue( RacerTable, victim )
		elseif victim:Team() == TEAM_POLICE.ID then
			Disqualify( victim, "Died in the race." )
			table.RemoveByValue( CopTable, victim )
		end
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

hook.Add( "EntityTakeDamage", "HP_SimfphysDamage", function( veh, dam ) --Simfphy's damage support
	if veh:GetClass() == "gmod_sent_vehicle_fphysics_base" then
		local driver = veh:GetDriver()
		if IsValid( driver ) and driver:Team() != TEAM_NONE.ID then
			local health = veh:GetCurHealth()
			if health <= 0 or veh.destroyed then
				Disqualify( driver, "Vehicle was destroyed." )
			end
		end
	end
end )

local function SaveVehPosAng( ply )
	local veh = ply:GetVehicle()
	local vehpos
	local vehang
	if veh.fphysSeat then
		local parent = veh.base
		vehpos = parent:GetPos()
		vehang = parent:GetAngles()
	else
		vehpos = veh:GetPos()
		vehang = veh:GetAngles()
	end
	ply.VehResetPos = {}
	ply.VehResetPos.Pos = vehpos
	ply.VehResetPos.Ang = vehang
end

local TrackerCooldown = 0
hook.Add( "Think", "HP_CarTracker", function()
	if !GetGlobalBool( "RaceStarted" ) or TrackerCooldown > CurTime() then return end
	for k,v in pairs( player.GetAll() ) do
		if IsValid( v ) and v:InVehicle() then
			if v:Team() != TEAM_NONE.ID then
				SaveVehPosAng( v )
				TrackerCooldown = CurTime() + 3
			end
		end
	end
end )

hook.Add( "OnEntityWaterLevelChanged", "HP_CheckWaterLevel", function( ent, old, new )
	if GetGlobalBool( "RaceStarted" ) and GetGlobalInt( "RaceMode" ) == 1 then
		local class = ent:GetClass()
		local driver
		if class == "prop_vehicle_jeep" and IsValid( ent:GetDriver() ) then
			if new == 3 then
				driver = ent:GetDriver()
			end
		elseif class == "gmod_sent_vehicle_fphysics_base" then
			if ent.IsInWater then
				driver = ent.DriverSeat:GetDriver()
			end
		end
		if IsValid( driver ) then
			if driver:Team() != TEAM_NONE.ID then
				Disqualify( driver, "Vehicle is waterlogged." )
			end
		end
	end
end )

hook.Add( "InitPostEntity", "HP_InitPostEntity", function()
	if simfphys then
		RunConsoleCommand( "sv_simfphys_damagemultiplicator", 1.5 )
		RunConsoleCommand( "sv_simfphys_fuel", 0 )
	end
	if AM_Vehicles then
		RunConsoleCommand( "AM_Config_HealthOverride", 100 )
		RunConsoleCommand( "AM_Config_FuelEnabled", 0 )
	end

	local version
	local color_blue = Color( 0, 0, 255 )
	MsgC( color_blue, "\nHot Pursuit version "..HP_VERSION.." successfully loaded.\n" )
	http.Fetch( "https://raw.githubusercontent.com/LambdaGaming/Hot-Pursuit/master/version.txt",
		function( body, len, headers, code )
			version = tonumber( body )
		end,
		function( error )
			MsgC( color_blue, "\nWarning: Hot Pursuit version check failed to load. Error message: "..error.."\n" )
			return
		end
	)
	if !isnumber( version ) then
		MsgC( color_blue, "\nWarning: Hot Pursuit version check failed to load. Either Github is down or OP screwed up again.\n" )
		return
	end
	if HP_VERSION < version then
		MsgC( color_blue, "\nWarning: Hot Pursuit is out of date! Please update through the workshop or Github.\n" )
	end
end )
