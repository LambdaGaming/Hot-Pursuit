
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
	end
end

function ENT:StartTouch( ent )
	if CLIENT then return end
	if !GetGlobalBool( "RaceStarted" ) then return end
	local isveh = ent:IsVehicle()
	if isveh then
		local driver = ent:GetDriver()
		if IsValid( driver ) and driver:Team() == TEAM_RACER.ID and !table.HasValue( RacerTable, driver ) then
			if GetGlobalBool( "RaceCountdown" ) then
				Disqualify( driver, "Crossing starting line during countdown." )
				return
			end
			table.insert( RacerTable, driver )
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end