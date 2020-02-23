
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
	local SpawnPos = tr.HitPos + tr.HitNormal
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
		self:PhysicsInit( SOLID_VPHYSICS )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( false )
		end

		local changedvec
		local ang = self:GetAngles()
		if ang.y == 90 then
			changedvec = Vector( 150, 0, 0 )
		else
			changedvec = Vector( 0, 150, 0 )
		end

		local e = ents.Create( "prop_dynamic" )
		e:SetModel( self:GetModel() )
		e:SetPos( self:GetPos() + changedvec )
		e:SetAngles( self:GetAngles() )
		e:SetParent( self )
		e:Spawn()

		local e2 = ents.Create( "prop_dynamic" )
		e2:SetModel( self:GetModel() )
		e2:SetPos( self:GetPos() - changedvec )
		e2:SetAngles( self:GetAngles() )
		e2:SetParent( self )
		e2:Spawn()
	end
end

if SERVER then
	function ENT:Think()
		for k,v in pairs( ents.FindInSphere( self:GetPos(), 150 ) ) do
			if IsValid( v ) and v:IsVehicle() and !v:GetNWBool( "IsAutomodSeat" ) and IsValid( v:GetDriver() ) then
				local driver = v:GetDriver()
				if driver.CutCooldown and driver.CutCooldown > CurTime() then return end
				HPNotifyAll( "Possible track cutting from "..driver:Nick().."." )
				driver.CutCooldown = CurTime() + 5
			end
		end
		self:NextThink( CurTime() + 1 )
		return true
	end
end