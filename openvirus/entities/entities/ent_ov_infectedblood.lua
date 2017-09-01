-- This is an entity created by infected that have died

if ( SERVER ) then AddCSLuaFile() end

ENT.Type = "anim"

ENT.Material = Material( "effects/splash4" )
ENT.LifeTime = 0
ENT.SpriteSize = 8


-- Initialize the entity
function ENT:Initialize()

	self:SetModel( "models/weapons/w_bugbait.mdl" )
	self:DrawShadow( false )

	self.LifeTime = CurTime() + 3
	self.SpriteSize = math.random( 8, 16 )

	self:SetCustomCollisionCheck( true )

	if ( SERVER ) then
	
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:CollisionRulesChanged()
	
		self:PhysWake()
	
	end

end


-- Think
function ENT:Think()

	-- Kill the entity
	if ( self.LifeTime < CurTime() ) then
	
		if ( SERVER ) then self:Remove() end
	
	end

end


-- Draw the entity
if ( CLIENT ) then

	function ENT:Draw()
	
		-- Draw a sprite
		render.SetMaterial( self.Material )
		render.DrawSprite( self.Entity:GetPos(), self.SpriteSize, self.SpriteSize, Color( 180, 255, 0, math.Remap( math.Clamp( self.LifeTime - CurTime(), 0, 2 ), 0, 2, 0, 255 ) ) )
	
	end

end
