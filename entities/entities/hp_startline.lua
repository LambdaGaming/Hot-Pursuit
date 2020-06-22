
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
	if HP_CONFIG_VEHICLE_CLASSES[ent:GetClass()] then
		local driver
		if ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then --Simpfhy's support
			local parent = ent:GetBaseEnt()
			if IsValid( parent ) and parent.DriverSeat and IsValid( parent.DriverSeat:GetDriver() ) then
				driver = parent.DriverSeat:GetDriver()
			end
		else
			driver = ent:GetDriver()
		end
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
