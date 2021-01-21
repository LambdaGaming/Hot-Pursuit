
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Starting Line"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Category = "Hot Pursuit"

function ENT:SpawnFunction( ply, tr, name )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 5
	local ent = ents.Create( name )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
    self:SetModel( "models/hunter/plates/plate3x8.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial( "hotpursuit/finishline" )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		self:SetUseType( SIMPLE_USE )

		local e = ents.Create( "prop_dynamic" )
		e:SetModel( "models/hunter/triangles/075x075mirrored.mdl" )
		e:SetMaterial( "models/weapons/v_slam/new light2" )
		e:SetPos( self:GetPos() + Vector( 0, 0, 0.5 ) )
		e:SetAngles( self:GetAngles() )
		e:SetParent( self )
		e:Spawn()
	end
end

function ENT:StartTouch( ent )
	if CLIENT or !GetGlobalBool( "RaceStarted" ) then return end
	local class = ent:GetClass()
	if HP_CONFIG_VEHICLE_CLASSES[class] then
		local driver
		if class == "gmod_sent_vehicle_fphysics_wheel" then --Simpfhy's support
			local parent = ent:GetBaseEnt()
			if IsValid( parent ) and parent.DriverSeat and IsValid( parent.DriverSeat:GetDriver() ) then
				driver = parent.DriverSeat:GetDriver()
			end
		else
			driver = ent:GetDriver()
		end
		if IsValid( driver ) and driver:Team() == TEAM_RACER.ID then
			local laps = GetTotalLaps()
			if GetGlobalBool( "RaceCountdown" ) then
				Disqualify( driver, "Crossing starting line during countdown." )
				return
			end
			if driver.LapCooldown and driver.LapCooldown > CurTime() then return end
			if !table.HasValue( RacerTable, driver ) then
				table.insert( RacerTable, driver )
			end
			driver:SetNWInt( "HP_Laps", math.Clamp( driver:GetNWInt( "HP_Laps" ) + 1, 0, laps + 1 ) )
			driver.LapCooldown = CurTime() + 10
			if driver:GetNWInt( "HP_Laps" ) == laps + 1 and laps > 1 then
				if driver:Team() != TEAM_RACER.ID or driver.Finished then return end
				driver.Finished = true
				HPNotifyAll( driver:Nick().." has finished!" )
				table.insert( FinishedPly, driver )
				table.RemoveByValue( RacerTable, driver )

				if !timer.Exists( "FinishTimer" ) then
					timer.Create( "FinishTimer", HP_CONFIG_FINISH_TIMER, 1, function() end )
				end

				for k,v in ipairs( player.GetAll() ) do
					if v:Team() == TEAM_RACER.ID and !v.Finished then
						return
					end
				end

				local first = FinishedPly[1]
				HPNotifyAll( first:Nick().." has won the race!" )
				EndRace()
				timer.Remove( "FinishTimer" )
			end
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
