
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
		self:SetUseType( SIMPLE_USE )
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