-- Dual Pistols

SWEP.PrintName = "#weapon_ov_dualpistol"
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "OV_DualPistol"
SWEP.Primary.DualAmmoUsed = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DualAmmoUsed = 0

SWEP.Weight = 2
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.CSMuzzleFlashes = true


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "duel" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
    if ( self.Primary.DualAmmoUsed >= 15 ) then return end

    self.Weapon:EmitSound( "Weapon_Elite.Single" )

    self:ShootBullet( 10, 1, 0.04 )

    self:TakePrimaryAmmo( 1 )
    if ( IsFirstTimePredicted() ) then self.Primary.DualAmmoUsed = self.Primary.DualAmmoUsed + 1 end

    self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.1 )

end


-- Secondary attack
function SWEP:SecondaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
    if ( self.Secondary.DualAmmoUsed >= 15 ) then return end

    self.Weapon:EmitSound( "Weapon_Elite.Single" )

    self:ShootBullet( 10, 1, 0.04 )
    self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

    self:TakePrimaryAmmo( 1 )
    if ( IsFirstTimePredicted() ) then self.Secondary.DualAmmoUsed = self.Secondary.DualAmmoUsed + 1 end

    self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

    self:SetNextPrimaryFire( CurTime() + 0.1 )

end


-- Reload
function SWEP:Reload()

    self.Weapon:DefaultReload( ACT_VM_RELOAD )
    self.Primary.DualAmmoUsed = 0
    self.Secondary.DualAmmoUsed = 0

end


if ( CLIENT ) then

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		surface.SetFont( "CSTRIKETypeDeath" )
		surface.SetTextColor( 255, 255, 255, a )
		surface.SetTextPos( x + ( w / 3 ), y + ( h / 2.5 ) )
		surface.DrawText( "s" )
	
	end

end
