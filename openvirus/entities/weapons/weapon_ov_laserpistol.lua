-- Laser Pistol

SWEP.PrintName = "#weapon_ov_laserpistol"
SWEP.UseHands = true

SWEP.ViewModelFOV = 58
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = 11
SWEP.Primary.DefaultClip = 11
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

	self:ShootBullet( 19, 1, 0.005 )

	self:TakePrimaryAmmo( 1 )

	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

	self:SetNextPrimaryFire( CurTime() + 0.1 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

	return

end


-- Reload
function SWEP:Reload()

	-- Play a sound
	if ( ( self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) > 0 ) && ( self.Weapon:Clip1() < self.Primary.DefaultClip ) ) then
	
		self.Weapon:EmitSound( "weapons/cguard/charging.wav", 75, 100, 0.7 )
	
	end

	self.Weapon:DefaultReload( ACT_VM_RELOAD )

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
	bullet.AmmoType = "OV_LazerPistol"
	bullet.Callback = function( attacker, trace, info ) self:ShootFirstRicochet( attacker, trace, info ) end

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end


-- First ricochet
function SWEP:ShootFirstRicochet( attacker, trace, info )

	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= trace.HitPos
	bullet.Dir 		= trace.HitNormal + ( trace.Normal * 0.6 )
	bullet.Spread 	= Vector( 0, 0, 0 )
	bullet.Tracer	= 1
	bullet.TracerName = "laserricotracer"
	bullet.Force	= 1
	bullet.Damage	= info:GetDamage() * 0.75
	bullet.AmmoType = "OV_LazerPistol"
	bullet.Callback = function( attacker, trace, info ) self:ShootLastRicochet( attacker, trace, info ) end

	attacker:FireBullets( bullet )

	if ( IsFirstTimePredicted() ) then sound.Play( "FX_RicochetSound.Ricochet", trace.HitPos ) end

end


-- Last ricochet
function SWEP:ShootLastRicochet( attacker, trace, info )

	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= trace.HitPos
	bullet.Dir 		= trace.HitNormal + ( trace.Normal * 0.6 )
	bullet.Spread 	= Vector( 0, 0, 0 )
	bullet.Tracer	= 1
	bullet.TracerName = "laserricotracer"
	bullet.Force	= 1
	bullet.Damage	= info:GetDamage() * 0.75
	bullet.AmmoType = "OV_LazerPistol"

	attacker:FireBullets( bullet )

	if ( IsFirstTimePredicted() ) then sound.Play( "FX_RicochetSound.Ricochet", trace.HitPos ) end

end


-- Whip it out (hue)
function SWEP:Deploy()

	self.Weapon:EmitSound( "openvirus/effects/ov_deploy_scifi.wav" )
	return true

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
	
		surface.SetFont( "HL2MPTypeDeath" )
		surface.SetTextColor( 255, 255, 255, a )
		surface.SetTextPos( x + ( w / 2.75 ), y + ( h / 2.5 ) )
		surface.DrawText( "-" )
	
	end

end
