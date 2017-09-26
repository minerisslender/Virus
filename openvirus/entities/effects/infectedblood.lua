-- This is an entity created by infected

if ( SERVER ) then AddCSLuaFile() end


-- Initialize the effect
function EFFECT:Init( data )

	self.Data = data
	self.LifeTime = CurTime() + 5
	self.Particles = math.random( 12, 24 )

	if ( !ov_cl_infected_blood:GetBool() ) then return end

	self.ParticleEmitter = ParticleEmitter( self.Data:GetOrigin(), false )
	for pnum = 1, self.Particles do
	
		self.Particle = self.ParticleEmitter:Add( "effects/splash4", self.Data:GetOrigin() )
		if ( self.Particle ) then
		
			self.Particle:SetAngles( self.Data:GetAngles() )
			self.Particle:SetVelocity( Vector( math.random( -160, 160 ), math.random( -160, 160 ), 0 ) )
			self.Particle:SetGravity( Vector( 0, 0, GetConVar( "sv_gravity" ):GetFloat() * -1 ) )
			self.Particle:SetCollide( true )
			self.Particle:SetBounce( 0.5 )
			self.Particle:SetColor( 180, 255, 0 )
			self.Particle:SetLifeTime( 0 )
			self.Particle:SetDieTime( 4 )
			self.Particle:SetStartAlpha( 255 )
			self.Particle:SetEndAlpha( 0 )
			self.Particle:SetStartSize( math.random( 6, 12 ) )
			self.Particle:SetEndSize( 0 )
			self.Particle:SetLighting( false )
		
		end
	
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
