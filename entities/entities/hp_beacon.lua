
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Beacon"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Hot Pursuit"

function ENT:SpawnFunction( ply, tr, name )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal
	local ent = ents.Create( name )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
    self:SetModel( "models/props_junk/TrafficCone001a.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
		end
		SetGlobalBool( "BeaconActive", true )
		timer.Simple( HP_CONFIG_BEACON_TIME, function()
			SetGlobalBool( "BeaconActive", false )
			self:Remove()
		end )
	end
end