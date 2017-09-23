-- Player meta stuff
local meta = FindMetaTable( "Player" )
if ( !meta ) then return end

if ( SERVER ) then AddCSLuaFile() end


-- Functions down here
-- Infect the player
function meta:InfectPlayer( ply )

	if ( CLIENT ) then return end
	if ( self:Team() != TEAM_SURVIVOR ) then return end

	self:SetFOV( 0, 0 )
	self:SetHealth( GAMEMODE.OV_Infected_Health )
	self:SetTeam( TEAM_INFECTED )
	self:SetFrags( 0 )
	self:SetDeaths( 0 )
	self:SetBloodColor( DONT_BLEED )
	if ( SERVER && self:FlashlightIsOn() ) then self:Flashlight( false ) end

	GAMEMODE:SetPlayerSpeed( self, GAMEMODE.OV_Infected_Speed, GAMEMODE.OV_Infected_Speed )

	hook.Call( "PlayerLoadout", GAMEMODE, self )
	hook.Call( "PlayerSetModel", GAMEMODE, self )

	local InfoText_PLYNAME = ""
	if ( ply && ply:IsValid() && ply:IsPlayer() ) then InfoText_PLYNAME = string.upper( ply:Name() ).." " end

	net.Start( "OV_SendInfoText" )
		net.WriteString( InfoText_PLYNAME.."INFECTED "..string.upper( self:Name() ) )
		net.WriteColor( Color( 0, 255, 0 ) )
		net.WriteInt( 5, 4 )
	net.Broadcast()

	-- Print in console
	if ( ply && ply:IsValid() && ply:IsPlayer() ) then
	
		PrintMessage( HUD_PRINTCONSOLE, self:Name().." was infected by "..ply:Name().."\n" )
	
	else
	
		PrintMessage( HUD_PRINTCONSOLE, self:Name().." was infected\n" )
	
	end

	-- Give the player who infected this player a point
	if ( ply && ply:IsValid() && ply:IsPlayer() ) then ply:AddFrags( 1 ) end

	-- Call the round to end if no survivors
	if ( team.NumPlayers( TEAM_SURVIVOR ) < 1 ) then
	
		GAMEMODE:EndMainRound()
	
	end

end


-- Set the Infected Infection Status
function meta:SetInfectionStatus( bool )

	if ( CLIENT ) then return end
	if ( !bool ) then return end
	if ( tobool( bool ) == self:GetNWBool( "InfectionStatus", false ) ) then return end

	if ( tobool( bool ) ) then
	
		-- Play a sound
		self:EmitSound( "ambient/fire/gascan_ignite1.wav", 90, 110 )
	
		-- Start enraged mode here
		if ( ( team.NumPlayers( TEAM_INFECTED ) < 2 ) && ( self:Team() == TEAM_INFECTED ) && ( self:Deaths() > 1 ) ) then
		
			self:SetEnragedStatus( 1 )
		
		end
	
	end

	self:SetNWBool( "InfectionStatus", tobool( bool ) )

end


-- Get the Infected Infection Status
function meta:GetInfectionStatus()

	return self:GetNWBool( "InfectionStatus", false )

end


-- Set the player Adrenaline Status
function meta:SetAdrenalineStatus( bool )

	if ( CLIENT ) then return end
	if ( !bool ) then return end

	if ( tobool( bool ) ) then
	
		GAMEMODE:SetPlayerSpeed( self, GAMEMODE.OV_Survivor_AdrenSpeed, GAMEMODE.OV_Survivor_AdrenSpeed )
	
	else
	
		GAMEMODE:SetPlayerSpeed( self, GAMEMODE.OV_Survivor_Speed, GAMEMODE.OV_Survivor_Speed )
	
	end

	self:SetNWBool( "AdrenalineStatus", tobool( bool ) )

end


-- Get the player Adrenaline Status
function meta:GetAdrenalineStatus()

	return self:GetNWBool( "AdrenalineStatus", false )

end


-- Set the Infected enraged status
function meta:SetEnragedStatus( bool )

	if ( CLIENT ) then return end
	if ( !bool ) then return end

	if ( tobool( bool ) ) then
	
		if ( self:Team() == TEAM_INFECTED ) then
		
			GAMEMODE:SetPlayerSpeed( self, GAMEMODE.OV_Infected_EnrageSpeed, GAMEMODE.OV_Infected_EnrageSpeed )
			self:SetColor( Color( 255, 180, 0 ) )
			self:SetPlayerColor( Vector( math.Remap( 255, 0, 255, 0, 1 ), math.Remap( 180, 0, 255, 0, 1 ), 0 ) )
			self:SetMaxHealth( GAMEMODE.OV_Infected_EnrageHealth )
			self:SetHealth( GAMEMODE.OV_Infected_EnrageHealth )
		
			net.Start( "OV_SendInfoText" )
				net.WriteString( string.upper( self:Name() ).." IS ENRAGED" )
				net.WriteColor( Color( 255, 0, 0 ) )
				net.WriteInt( 5, 4 )
			net.Broadcast()
		
		end
	
	else
	
		if ( self:Team() == TEAM_INFECTED ) then
		
			GAMEMODE:SetPlayerSpeed( self, GAMEMODE.OV_Infected_Speed, GAMEMODE.OV_Infected_Speed )
			self:SetColor( Color( 180, 255, 0 ) )
			self:SetPlayerColor( Vector( math.Remap( 180, 0, 255, 0, 1 ), math.Remap( 255, 0, 255, 0, 1 ), 0 ) )
			self:SetMaxHealth( GAMEMODE.OV_Infected_Health )
			if ( self:Alive() && ( self:Health() > GAMEMODE.OV_Infected_Health ) ) then
			
				self:SetHealth( GAMEMODE.OV_Infected_Health )
			
			end
		
		end
	
	end

	self:SetNWBool( "EnragedStatus", tobool( bool ) )

end


-- Get the Infected enraged status
function meta:GetEnragedStatus()

	return self:GetNWBool( "EnragedStatus", false )

end
