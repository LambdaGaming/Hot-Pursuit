
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Barrier"
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
    self:SetModel( "models/props_c17/concrete_barrier001a.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:SetUseType( SIMPLE_USE )
		constraint.NoCollide( self, game.GetWorld(), 0, 0 )
		local e = ents.Create( "prop_dynamic" )
		e:SetModel( self:GetModel() )
		e:SetPos( self:GetPos() + Vector( 0, 150, 0 ) )
		e:SetAngles( self:GetAngles() )
		e:SetParent( self )
		e:Spawn()

		local e2 = ents.Create( "prop_dynamic" )
		e2:SetModel( self:GetModel() )
		e2:SetPos( self:GetPos() + Vector( 0, -150, 0 ) )
		e2:SetAngles( self:GetAngles() )
		e2:SetParent( self )
		e2:Spawn()
	end
end