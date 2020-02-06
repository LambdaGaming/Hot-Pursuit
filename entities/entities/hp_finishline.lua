
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Finish Line"
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
	self:SetColor( Color( 0, 255, 0 ) )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( false )
		end
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:StartTouch( ent )
	if CLIENT then return end
	if !GetGlobalBool( "RaceStarted" ) then return end
	local isveh = ent:IsVehicle()
	local isply = ent:IsPlayer()
	if isveh or isply then
		if isveh then
			local driver = ent:GetDriver()
			if IsValid( driver ) then
				if driver:Team() != TEAM_RACER.ID or driver.Finished then return end
				driver.Finished = true
				HPNotifyAll( ent:GetDriver():Nick().." has finished!" )
				table.insert( FinishedPly, driver )
				table.RemoveByValue( RacerTable, driver )
			end
		elseif isply then
			if ent:Team() != TEAM_RACER.ID or ent.Finished then return end
			ent.Finished = true
			HPNotifyAll( ent:Nick().." has finished!" )
			table.insert( FinishedPly, ent )
			table.RemoveByValue( RacerTable, ent )
		end

		if !timer.Exists( "FinishTimer" ) then
			timer.Create( "FinishTimer", HP_CONFIG_FINISH_TIMER, 1, function() end )
		end

		for k,v in pairs( player.GetAll() ) do
			if v:Team() == TEAM_RACER.ID and !v.Finished then
				return
			end
		end

		EndRace()

		local first = FinishedPly[1]
		if !first then return end
		HPNotifyAll( first:Nick().." has won the race!" )
		timer.Remove( "FinishTimer" )
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end