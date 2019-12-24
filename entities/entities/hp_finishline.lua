
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
    self:SetModel( "models/error.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end
 
    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:StartTouch( ent )
	if CLIENT then return end
	if ent:IsVehicle() and IsValid( ent:GetDriver() ) and GetGlobalBool( "RaceStarted" ) and !ent.Finished then
		ent.Finished = true
		for k,v in pairs( player.GetAll() ) do
			HPNotify( v, ent:GetDriver():Nick().." has finished!" )
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end