-- Laser Rifle

SWEP.PrintName = "#weapon_ov_laserrifle"
SWEP.UseHands = true

SWEP.ViewModelFOV = 58
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Charge = 0
SWEP.Primary.ChargeSlowdown = false
SWEP.Primary.BeginChargingTime = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false


-- Initialize the weapon
function SWEP:Initialize()

	self:SetHoldType( "ar2" )

end


-- Primary attack
function SWEP:PrimaryAttack()

	self.Weapon:EmitSound( "openvirus/effects/ov_laser.wav", 75, 125 )

	self:ShootBullet( 16, 1, 0.015 )

	self.Owner:ViewPunch( Angle( -0.25, 0, 0 ) )

	if ( IsFirstTimePredicted() ) then self.Primary.BeginChargingTime = CurTime() + 1.5 end

	self:SetNextPrimaryFire( CurTime() + math.Clamp( self.Primary.Charge / 100, 0.125, 1 ) )

end


-- Secondary attack
function SWEP:SecondaryAttack()

	return

end


-- Think
function SWEP:Think()

	-- Primary charge
	if ( IsValid( self.Owner ) && self.Owner:IsPlayer() && self.Owner:Alive() ) then
	
		if ( self.Owner:KeyDown( IN_ATTACK ) ) then
		
			if ( self.Primary.Charge < 100 ) then
			
				if ( IsFirstTimePredicted() ) then self.Primary.Charge = self.Primary.Charge + 0.2 end
			
				if ( !self.Primary.ChargeSlowdown && ( self.Primary.Charge > 90 ) ) then
				
					self.Primary.ChargeSlowdown = true
					self.Weapon:EmitSound( "npc/attack_helicopter/aheli_damaged_alarm1.wav", 110, 150, 0.75, CHAN_STATIC )
				
				end
			
				if ( self.Primary.Charge > 100 ) then
				
					self.Primary.Charge = 100
				
				end
			
			end
		
		else
		
			if ( ( self.Primary.BeginChargingTime < CurTime() ) && ( self.Primary.Charge > 0 ) ) then
			
				if ( IsFirstTimePredicted() ) then self.Primary.Charge = self.Primary.Charge - 0.4 end
			
				if ( self.Primary.ChargeSlowdown && ( self.Primary.Charge <= 90 ) ) then
				
					self.Primary.ChargeSlowdown = false
				
				end
			
				if ( self.Primary.Charge < 0 ) then
				
					self.Primary.Charge = 0
				
				end
			
			end
		
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
	bullet.TracerName = "plasmatracer"
	bullet.Force	= 1
	bullet.Damage	= damage

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end


if ( CLIENT ) then

	-- Draw a HUD
	function SWEP:DrawHUD()
	
		if ( self.Primary.Charge > 0 ) then
		
			draw.RoundedBox( 2, ScrW() / 2 - ( ScrH() * 0.25 / 2 ), ScrH() / 1.1, ScrH() * 0.25, ScrH() * 0.025, Color( 0, 0, 0, 200 ) )
			draw.RoundedBox( 1, ScrW() / 2 - ( ScrH() * 0.25 / 2 ) + 2, ScrH() / 1.1 + 2, ( ScrH() * 0.25 - 4 ) * ( self.Primary.Charge / 100 ), ScrH() * 0.025 - 4, Color( 255, math.Remap( self.Primary.Charge, 0, 100, 255, 0 ), math.Remap( self.Primary.Charge, 0, 100, 255, 0 ) ), 200 )
		
		end
	
	end

	-- Draw the weapon selection box
	function SWEP:DrawWeaponSelection( x, y, w, h, a )
	
		draw.RoundedBox( 6, x, y, w, h, Color( 0, 0, 100, a - 100 ) )
	
		surface.SetFont( "HL2MPTypeDeath" )
		surface.SetTextColor( 255, 255, 255, a )
		surface.SetTextPos( x + ( w / 3.25 ), y + ( h / 2.5 ) )
		surface.DrawText( "2" )
	
	end

end
