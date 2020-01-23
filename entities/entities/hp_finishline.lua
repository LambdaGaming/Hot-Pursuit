
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Finish Line"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
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
	self:SetMaterial( "phoenix_storms/stripes" )
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

local finishedply = {}
function ENT:StartTouch( ent )
	if CLIENT then return end
	if !GetGlobalBool( "RaceStarted" ) then return end
	if ent.Finished then return end
	local isveh = ent:IsVehicle()
	local isply = ent:IsPlayer()
	if isveh or isply then
		if isveh then
			local driver = ent:GetDriver()
			if IsValid( driver ) and driver:Team() == TEAM_RACER.ID then
				driver.Finished = true
				HPNotifyAll( ent:GetDriver():Nick().." has finished!" )
				table.insert( finishedply, driver )
			end
		elseif isply and ent:Team() == TEAM_RACER.ID then
			ent.Finished = true
			HPNotifyAll( ent:Nick().." has finished!" )
			table.insert( finishedply, ent )
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
		local first = finishedply[1]
		HPNotifyAll( first:Nick().." has won the race!" )
		timer.Remove( "FinishTimer" )
		finishedply = {}
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end