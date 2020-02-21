
AddCSLuaFile()

SWEP.PrintName = "Mine"
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

SWEP.MineCount = 2

function SWEP:Deploy()
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace()
    if self.Owner:GetPos():DistToSqr( tr.HitPos ) < 10000 then
		if self.MineCount > 0 then
			local e = ents.Create( "hp_mine" )
			e:SetPos( tr.HitPos )
			e:SetAngles( Angle( 0, self.Owner:GetAngles().y, 0 ) )
			e:Spawn()
			e:SetOwner( self.Owner )
			e:EmitSound( "HL1/fvox/beep.wav" )
			self.MineCount = self.MineCount - 1
			HPNotify( self.Owner, "You have placed a mine. You have "..self.MineCount.." mine(s) remaining." )
			if self.MineCount <= 0 then self:Remove() end
		end
    end
    self:SetNextPrimaryFire( CurTime() + 1 )
end