-- Laser Rifle

SWEP.PrintName = "#weapon_ov_laserrifle"
SWEP.UseHands = true

SWEP.ViewModelFOV = 60
SWEP.ViewModelDefaultFOV = 60
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "OV_LazerRifle"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "ar2" )

end


-- Primary attack
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end

    self.Weapon:EmitSound( "openvirus/effects/ov_laser.wav", 75, 125 )

    self:ShootBullet( 16, 1, 0.015 )

    self:TakePrimaryAmmo( 1 )

    self.Owner:ViewPunch( Angle( -0.25, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.125 )

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
	bullet.TracerName = "plasmatracer"
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
		surface.SetTextPos( x + ( w / 3.25 ), y + ( h / 2.5 ) )
		surface.DrawText( "2" )
	
	end

end
