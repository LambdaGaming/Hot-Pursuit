
AddCSLuaFile()

SWEP.PrintName = "Beacon"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Category = "Hot Pursuit"
SWEP.Slot = 3

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.BeaconCount = 3

function SWEP:Deploy()
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace()
    if self.Owner:GetPos():DistToSqr( tr.HitPos ) < 10000 then
		if self.BeaconCount > 0 then
			if GetGlobalBool( "BeaconActive" ) then
				HPNotify( self.Owner, "There is already an active beacon on the map!" )
				return
			end
			local e = ents.Create( "hp_beacon" )
			e:SetPos( tr.HitPos + Vector( 0, 0, 20 ) )
			e:SetAngles( Angle( 0, self.Owner:GetAngles().y, 0 ) )
			e:Spawn()
			e:SetOwner( self.Owner )
			e:EmitSound( "buttons/button19.wav" )
			self.BeaconCount = self.BeaconCount - 1
			HPNotify( self.Owner, "You have placed a beacon. You have "..self.BeaconCount.." beacon(s) remaining." )
			if self.BeaconCount <= 0 then self:Remove() end
		end
    end
    self:SetNextPrimaryFire( CurTime() + 1 )
end