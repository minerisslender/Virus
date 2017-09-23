-- This is an entity created when survivors spawn

if ( SERVER ) then AddCSLuaFile() end


-- Initialize the effect
function EFFECT:Init( data )

	self.Data = data
	self.LifeTime = CurTime() + 2

	self.ParticleEmitter = ParticleEmitter( self.Data:GetOrigin(), false )
		self.Particle = self.ParticleEmitter:Add( "effects/blueblackflash", self.Data:GetOrigin() )
		if ( self.Particle ) then
		
			self.Particle:SetAngles( self.Data:GetAngles() )
			self.Particle:SetColor( 180, 255, 0 )
			self.Particle:SetLifeTime( 0 )
			self.Particle:SetDieTime( 1 )
			self.Particle:SetStartAlpha( 255 )
			self.Particle:SetEndAlpha( 0 )
			self.Particle:SetStartSize( 64 )
			self.Particle:SetEndSize( 64 )
			self.Particle:SetLighting( false )
		
		end
	self.ParticleEmitter:Finish()

end


-- Think
function EFFECT:Think()

	if ( self.LifeTime < CurTime() ) then

		self:Remove()
	
	end

	return true

end


-- Render the effect
function EFFECT:Render()

	return true

end
