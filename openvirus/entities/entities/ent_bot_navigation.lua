-- Player NextBot navigation NPC

if ( SERVER ) then AddCSLuaFile() end

ENT.Base = "base_nextbot"

ENT.TargetPos = Vector( 0, 0, 0 )
ENT.DistanceTable = {}
ENT.Wandering = false
ENT.WanderingTimeout = 0
ENT.SpeedBoost = 0


-- Initialize the NPC
function ENT:Initialize()

	self:SetModel( "models/player/kleiner.mdl" )
	self:SetCustomCollisionCheck( true )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetSolid( SOLID_NONE )
	self:CollisionRulesChanged()

	self:SetNoDraw( true )

	self.Wandering = true
	self.TargetPos = self:FindSpot( "random" ) or Vector( 0, 0, 0 )

end


-- Pretty much the brain
function ENT:RunBehaviour()

	while ( true ) do
	
		if ( ov_sv_bot_slower && self.SpeedBoost ) then
		
			if ( ov_sv_bot_slower:GetBool() ) then
			
				self.SpeedBoost = 0
			
			else
			
				self.SpeedBoost = 32
			
			end
		
		end
	
		self.loco:SetDesiredSpeed( GAMEMODE.OV_Survivor_Speed + self.SpeedBoost )
		if ( self:GetOwner() && self:GetOwner():IsValid() && self:GetOwner():IsPlayer() ) then self.loco:SetDesiredSpeed( self:GetOwner():GetWalkSpeed() + self.SpeedBoost ) end
		self:MoveToPos( self.TargetPos )
	
		coroutine.yield()
	
	end


end


-- MoveToPos edit
function ENT:MoveToPos( pos, options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do
	
		if ( path:GetAge() > 0.1 ) then
		
			path:Compute( self, self.TargetPos )
		
		end
		path:Update( self )
	
		if ( options.draw ) then
		
			path:Draw()
		
		end
	
		if ( self.loco:IsStuck() ) then
		
			self:HandleStuck()
		
			return "stuck"
		
		end
	
		coroutine.yield()
	
	end

	return "ok"

end


-- Think
function ENT:Think()

	-- Positions we might go to
	if ( SERVER ) then
	
		if ( self:GetOwner() && self:GetOwner():IsValid() && self:GetOwner():IsPlayer() ) then
		
			self.DistanceTable = {}
			if ( self:GetOwner():Team() == TEAM_INFECTED ) then
			
				for _, ply in pairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
				
					if ( ply:IsValid() && ply:Alive() && ( ply != self:GetOwner() ) ) then
					
						-- Make a distance table
						table.insert( self.DistanceTable, self:GetPos():Distance( ply:GetPos() ) )
					
						-- Get nearest player and set the position to them
						if ( self:GetPos():Distance( ply:GetPos() ) == math.min( unpack( self.DistanceTable ) ) ) then
						
							self.TargetPos = ply:GetPos()
							if ( self.Wandering ) then self.Wandering = false end
						
						end
					
					end
				
				end
			
			end
		
		end
	
	end

	-- Wandering bots
	if ( SERVER ) then
	
		if ( self.Wandering ) then
		
			if ( self.WanderingTimeout < CurTime() ) then
			
				self.WanderingTimeout = CurTime() + 5
				self.TargetPos = self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 4096
			
			end
		
		end
	
	end

	-- Go back to our owner if we are not visible to them
	if ( SERVER ) then
	
		if ( self:GetOwner() && self:GetOwner():IsValid() && self:GetOwner():IsPlayer() && !self:GetOwner():Visible( self ) ) then
		
			self.Entity:SetPos( self:GetOwner():GetPos() )
		
		end
	
	end

end
