
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Mine"
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
    self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( false )
		end
	end
end

if SERVER then
	local function Explode( pos, mag, time )
		local e = ents.Create( "env_explosion" )
		e:SetPos( pos )
		e:Spawn()
		e:SetKeyValue( "iMagnitude", mag )
		if time <= 0 then
			e:Fire( "Explode", 0, 0 )
		else
			timer.Simple( time, function()
				e:Fire( "Explode", 0, 0 )
			end )
		end
	end

	function ENT:Think()
		for k,v in pairs( ents.FindInSphere( self:GetPos(), HP_CONFIG_MINE_RANGE ) ) do
			if v:IsVehicle() and IsValid( v:GetDriver() ) then
				Explode( self:GetPos(), HP_CONFIG_MINE_MAGNITUDE, 0 )
				self:Remove()
			end
		end
	end
end