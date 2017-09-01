-- Laser Pistol

SWEP.PrintName = "#weapon_ov_laserpistol"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "OV_LazerPistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "pistol" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end

    self.Weapon:EmitSound( "openvirus/effects/ov_laser.wav" )

    self:ShootBullet( 20, 1, 0.015 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.1 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

    return

end


-- Shoot bullets
function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= 1
	bullet.TracerName = "lasertracer"
	bullet.Force	= 1
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		surface.SetFont( "HL2MPTypeDeath" )
		surface.SetTextColor( 255, 255, 255, a )
		surface.SetTextPos( x + ( w / 2.75 ), y + ( h / 2.5 ) )
		surface.DrawText( "-" )
	
	end

end
