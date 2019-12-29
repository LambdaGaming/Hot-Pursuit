
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "hp_maps.lua" )

RacerTable = {}

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

util.AddNetworkString( "HPPlaySound" )
function HPPlaySound( ply, sound )
	net.Start( "HPPlaySound" )
	net.WriteString( sound )
	net.Send( ply )
end

function StartRace( type, timelimit )
	local mapconfig = HotPursuitMaps[game.GetMap()][type]
	for k,v in RandomPairs( player.GetAll() ) do --Randomize players so everyone's not in the same spot every race
		if !v:InVehicle() then
			v:ChatPrint( "Attempted to start a race but not all players are in their vehicles!" )
			return
		end
		if v:GetNWBool( "IsCop" ) then
			for a,b in pairs( mapconfig.PoliceSpawns ) do
				local veh = v:GetVehicle()
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
			end
		else
			for a,b in pairs( mapconfig.CarSpawns ) do
				local veh = v:GetVehicle()
				veh:SetPos( b[1] )
				veh:SetAngles( b[2] )
				table.insert( RacerTable, v )
			end
		end

		local countdown = 3
		HPNotify( v, "The race will begin soon!" )
		timer.Create( "RaceCountdown", 1, 4, function()
			if countdown > 0 then
				HPNotify( v, tostring( countdown ) ) --Will eventually be converted to a HUD element
				HPPlaySound( v, "buttons/blip1.wav" )
				countdown = countdown - 1
			else
				HPNotify( v, "GO!" )
				HPPlaySound( v, "plats/elevbell1.wav" )
			end
		end )
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

function EndRace( finishline )
	for k,v in pairs( ents.GetAll() ) do
		local removedents = {
			["hp_finishline"] = true,
			["automod_spikestrip"] = true,
			["hp_barrier"] = true
		}
		if v:IsVehicle() then v.Finished = false end
		if removedents[v:GetClass()] then v:Remove() end
	end
	RacerTable = {}
end

hook.Add( "PlayerSay", "HP_StartRaceCommand", function( ply, text )
	local split = string.Split( text, " " )
	if split[1] == "!start" then
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
		if !GetGlobalBool( "RaceStarted" ) then
			HPNotify( ply, "There is no race to end!" )
			return ""
		end
		EndRace()
	end
end )