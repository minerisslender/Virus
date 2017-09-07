-- LaserTracer taken from the Sandbox gamemode

EFFECT.Mat = Material( "effects/spark" )
EFFECT.SpriteMat = CreateMaterial( "flaktracer_flare1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/flare1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )


function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()

	local ent = data:GetEntity()
	local att = data:GetAttachment()

	if ( IsValid( ent ) && att > 0 ) then
	
		if ( ent.Owner == LocalPlayer() && !LocalPlayer():GetViewModel() != LocalPlayer() ) then ent = ent.Owner:GetViewModel() end
	
		local att = ent:GetAttachment( att )
		if ( att ) then
		
			self.StartPos = att.Pos
		
		end
	
	end

	self.Dir = self.EndPos - self.StartPos

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 1000 )
	self.Length = 0.5

	self.DieTime = CurTime() + self.TracerTime
	self.SpriteLifeTime = CurTime() + 0.25

end


function EFFECT:Think()

	return true

end


function EFFECT:Render()

	local fDelta = ( self.DieTime - CurTime() ) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 ) ^ 0.5

	if ( self.SpriteLifeTime >= CurTime() ) then
	
		render.SetMaterial( self.SpriteMat )
		render.DrawSprite( self.StartPos, 64, 64, Color( 255, 200, 0, 200 ) )
	
	end

	render.SetMaterial( self.Mat )

	local sinWave = math.sin( fDelta * math.pi )

	render.DrawBeam( self.EndPos - self.Dir * ( fDelta - sinWave * self.Length ), self.EndPos - self.Dir * ( fDelta + sinWave * self.Length ), 2 + sinWave * 16, 1, 0, Color( 255, 200, 0, 255 ) )

end
