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


SWEP.Charge = 0


-- Initialize the weapon
function SWEP:Initialize()

    self:SetHoldType( "ar2" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	if ( self.Charge > 0 ) then return end
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


-- Whip it out (hue)
function SWEP:Deploy()

	self.Charge = 0

	return true

end


-- Put it away
function SWEP:Holster()

	self.Charge = 0

	return true

end


-- Think
function SWEP:Think()

    if ( IsFirstTimePredicted() && self.Owner && self.Owner:IsValid() ) then
	
		-- Charge it up
		if ( self.Owner:KeyDown( IN_ATTACK2 ) && ( self.Charge < 100 ) ) then
		
            if ( self.Charge < 1 ) then self.Weapon:EmitSound( "weapons/ar2/ar2_reload_rotate.wav", 75, 100, 0.7, CHAN_WEAPON ) end
			if ( self.Charge >= 99 ) then self.Weapon:EmitSound( "weapons/ar2/ar2_reload_rotate.wav", 75, 150, 0.7, CHAN_WEAPON ) end
		
			self.Charge = self.Charge + 1
			self.ViewModelFOV = self.ViewModelDefaultFOV - self.Charge / 5
		
		end
	
		-- Lose charge if we stop holding the button
		if ( !self.Owner:KeyDown( IN_ATTACK2 ) && ( self.Charge > 0 ) ) then
		
			-- Do a thing
			if ( self.Charge >= 100 ) then
			
				self.Weapon:EmitSound( "NPC_CombineBall.Explosion" )
			
				util.ScreenShake( self.Owner:GetPos(), 64, 64, 0.25, 128 )
			
				local soniceffectpos = self.Weapon:GetAttachment( 1 ).Pos
				if ( CLIENT && !self.Owner:ShouldDrawLocalPlayer() ) then
				
					soniceffectpos = self.Owner:GetViewModel():GetAttachment( 1 ).Pos
				
				end
			
				local soniceffect = EffectData()
				soniceffect:SetOrigin( soniceffectpos )
				util.Effect( "cball_explode", soniceffect )
			
				local attackeyetrace = self.Owner:GetEyeTrace()
				if ( attackeyetrace.Entity && attackeyetrace.Entity:IsValid() && attackeyetrace.Entity:IsPlayer() && attackeyetrace.Entity:Alive() && ( attackeyetrace.Entity:Team() == TEAM_INFECTED ) && ( attackeyetrace.Entity:GetPos():Distance( self.Owner:GetPos() ) <= 512 ) ) then
				
					attackeyetrace.Entity:SetVelocity( ( attackeyetrace.Entity:GetPos() - ( self.Owner:GetPos() - Vector( 0, 0, 4 ) ) ) * math.Remap( attackeyetrace.Entity:GetPos():Distance( self.Owner:GetPos() ), 0, 300, 64, 0 ) )
				
				end
			
			end
		
			self.Charge = 0
			self.ViewModelFOV = self.ViewModelDefaultFOV
		
		end
	
		-- Stop it here
		if ( self.Charge > 100 ) then
		
			self.Charge = 100
		
		end
	
	end

end


-- Shoot bullets
function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= 1
	bullet.TracerName = "tooltracer"
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
