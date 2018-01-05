-- Initialize the player!


-- Functions down here
-- Called when a player picks up a weapon
function GM:PlayerCanPickupWeapon( ply, ent )

	-- Only survivors can pick up weapons not created by the map
	if ( ply:Team() != TEAM_SURVIVOR ) then return false end
	if ( ent:CreatedByMap() ) then return false end

	return true

end


-- Called when a player picks up an item
function GM:PlayerCanPickupItem( ply, ent )

	-- Only survivors can pick up items not created by the map
	if ( ply:Team() != TEAM_SURVIVOR ) then return false end
	if ( ent:CreatedByMap() ) then return false end

	return true

end


-- Player disconnected
function GM:PlayerDisconnected( ply )

	if ( OV_Game_InRound && ( player.GetCount() <= 2 ) ) then
	
		timer.Simple( 0.1, function() if ( OV_Game_InRound && ( player.GetCount() <= 1 ) ) then GAMEMODE:EndMainRound() end end )
	
	end

	if ( OV_Game_InRound && ( team.NumPlayers( TEAM_SURVIVOR ) <= 1 ) ) then
	
		timer.Simple( 0.1, function() if ( OV_Game_InRound && ( team.NumPlayers( TEAM_SURVIVOR ) <= 0 ) ) then GAMEMODE:EndMainRound() end end )
	
	end

	-- Update player ranking
	timer.Simple( 0.1, function() hook.Call( "PlayerRankCheckup", GAMEMODE ) end )

end


-- Called when the player is waiting for respawn
function GM:PlayerDeathThink( ply )

	-- Respawn players after a certain amount of time
	if ( ply.NextSpawnTime && ( ( ply.NextSpawnTime + 3 ) < CurTime() ) ) then
	
		ply:Spawn()
	
	end

end


-- Called when player uses the USE key
function GM:PlayerUse( ply, ent )

	-- Disable USE completely
	return false

end


-- Called when a player dies
function OV_PlayerDeath( ply, inflictor, attacker )

	-- If a player dies
	if ( ply:Team() == TEAM_SURVIVOR ) then
	
		-- Survivor managed to die in the round
		if ( OV_Game_InRound ) then ply:InfectPlayer() end
	
		ply:SetFOV( 0, 0 )
		ply:SetAdrenalineStatus( 0 )
		ply.timeAdrenalineStatus = 0
		ply:RemoveAllItems()
	
	elseif ( ply:Team() == TEAM_INFECTED ) then
	
		ply:SetEnragedStatus( 0 )
		ply:SetInfectionStatus( 0 )
		ply.timeInfectionStatus = 0
		ply:SetColor( Color( 255, 255, 255 ) )
	
		-- Infected blood effects
		if ( ov_sv_infected_blood:GetBool() ) then
		
			local bloodeffect = EffectData()
			bloodeffect:SetOrigin( ply:LocalToWorld( ply:OBBCenter() ) )
			util.Effect( "infectedblood", bloodeffect )
		
		end
	
	end

	-- Update player ranking
	hook.Call( "PlayerRankCheckup", GAMEMODE )

end
hook.Add( "PlayerDeath", "OV_PlayerDeath", OV_PlayerDeath )


-- Called before the first spawn
function GM:PlayerInitialSpawn( ply )

	-- player_manager initialize
	player_manager.SetPlayerClass( ply, "player_virus" )

	-- Time survived stuff
	ply:SetNWFloat( "OV_TimeSurvived", 0 )

	-- Select these teams at initial spawn
	if ( OV_Game_WaitingForPlayers || OV_Game_PreRound ) then
	
		ply:SetTeam( TEAM_SURVIVOR )
	
	elseif ( OV_Game_InRound ) then
	
		ply:SetTeam( TEAM_INFECTED )
	
	elseif ( OV_Game_EndRound ) then
	
		ply:SetTeam( TEAM_SPECTATOR )
	
	end

	-- Update networked stuff
	net.Start( "OV_UpdateRoundStatus" )
		net.WriteBool( OV_Game_WaitingForPlayers )
		net.WriteBool( OV_Game_PreRound )
		net.WriteBool( OV_Game_InRound )
		net.WriteBool( OV_Game_EndRound )
		net.WriteInt( OV_Game_Round, 8 )
		net.WriteInt( OV_Game_MaxRounds, 8 )
	net.Send( ply )

	if ( timer.Exists( "OV_RoundTimer" ) ) then
	
		net.Start( "OV_SendTimerCount" )
			net.WriteFloat( timer.TimeLeft( "OV_RoundTimer" ) )
		net.Send( ply )
	
	end

	net.Start( "OV_SettingsEnabled" )
		net.WriteBool( ov_sv_enable_player_radar:GetBool() )
		net.WriteBool( ov_sv_enable_player_ranking:GetBool() )
	net.Send( ply )

end


-- Called when the player spawns
function GM:PlayerSpawn( ply )

	-- Player is excluded from the game
	if ( ply.excludeFromGame ) then ply:SetTeam( TEAM_SPECTATOR ) end

	-- Player is in spectator
	if ( ply:Team() == TEAM_SPECTATOR ) then
	
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		return
	
	end

	-- Get out of spectator if we are
	ply:UnSpectate()

	-- Set up the player hands
	ply:SetupHands()

	-- player_manager stuff
	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

	-- Player Collision
	ply:SetCustomCollisionCheck( true )
	ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	ply:CollisionRulesChanged()

	-- Reset player stats
	ply:AddEFlags( EFL_IN_SKYBOX )
	ply:SetFOV( 0, 0 )
	ply:SetColor( Color( 255, 255, 255 ) )
	ply:SetBloodColor( BLOOD_COLOR_RED )
	ply:SetInfectionStatus( 0 )
	ply:SetEnragedStatus( 0 )
	ply:SetAdrenalineStatus( 0 )
	ply.timeInfectionStatus = 0
	ply.timeAdrenalineStatus = 0

	-- Time the Infection status
	if ( ply:Team() == TEAM_INFECTED ) then ply.timeInfectionStatus = CurTime() + 2 end

	-- Player Speed
	if ( ply:Team() == TEAM_SURVIVOR ) then
	
		GAMEMODE:SetPlayerSpeed( ply, GAMEMODE.OV_Survivor_Speed, GAMEMODE.OV_Survivor_Speed )
	
	elseif ( ( ply:Team() == TEAM_SPECTATOR ) || ( ply:Team() == TEAM_INFECTED ) ) then
	
		GAMEMODE:SetPlayerSpeed( ply, GAMEMODE.OV_Infected_Speed, GAMEMODE.OV_Infected_Speed )
	
	end

	-- Player Loadout
	hook.Call( "PlayerLoadout", GAMEMODE, ply )

	-- Player Model
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	-- Do a spawn effect for clients
	if ( ply:Team() == TEAM_SURVIVOR ) then
	
		local spawneffect = EffectData()
		spawneffect:SetOrigin( ply:GetPos() + Vector( 0, 0, 36 ) )
		util.Effect( "survivorspawn", spawneffect )
	
	elseif ( ply:Team() == TEAM_INFECTED ) then
	
		local spawneffect = EffectData()
		spawneffect:SetOrigin( ply:GetPos() + Vector( 0, 0, 36 ) )
		util.Effect( "infectedspawn", spawneffect )
	
	end

	-- Respawn sound
	ply:EmitSound( "openvirus/effects/ov_respawn.wav", 75, 90, 0.5 )

end


-- Called when we are going to set the player model
function GM:PlayerSetModel( ply )

	-- Run this like normal
	player_manager.RunClass( ply, "SetModel" )

	-- Bots
	if ( ply:IsBot() ) then
	
		ply:SetModel( table.Random( player_manager.AllValidModels() ) )
	
	end

	-- Infected player
	if ( ply:Team() == TEAM_INFECTED ) then
	
		ply:SetModel( GAMEMODE.OV_Infected_Model )
	
	end

	-- Set the player model to something different
	if ( ( ply:Team() == TEAM_SURVIVOR ) && ( ply:GetModel() == GAMEMODE.OV_Infected_Model ) ) then
	
		ply:SetModel( "models/player/kleiner.mdl" )
	
	end

	-- Last but not least we should set the model color
	if ( ply:Team() == TEAM_SURVIVOR ) then
	
		ply:SetPlayerColor( Vector( ply:GetInfo( "cl_playercolor" ) ) )
	
		-- Bots have a random color
		if ( ply:IsBot() ) then
		
			ply:SetPlayerColor( Vector( math.Rand( 0, 1 ), math.Rand( 0, 1 ), math.Rand( 0, 1 ) ) )
		
		end
	
	elseif ( ply:Team() == TEAM_INFECTED ) then
	
		ply:SetPlayerColor( Vector( math.Remap( 180, 0, 255, 0, 1 ), math.Remap( 255, 0, 255, 0, 1 ), 0 ) )
	
	end

end


-- Called when the player spawns and the PlayerLoadout hook is called
function GM:PlayerLoadout( ply )

	-- Remove all items
	ply:RemoveAllItems()

	-- Waiting for players session
	if ( OV_Game_WaitingForPlayers ) then return end

	-- Spectator
	if ( ply:Team() == TEAM_SPECTATOR ) then return end

	-- Is on infected team
	if ( ply:Team() == TEAM_INFECTED ) then
	
		ply:SetColor( Color( 180, 255, 0 ) )
		ply:SetBloodColor( DONT_BLEED )
		ply:SetNWInt( "InfectedLastHurt", CurTime() + 4 )
	
		return
	
	end

	-- Survivor loadout
	for k, v in pairs( OV_Game_WeaponLoadout ) do
	
		ply:Give( tostring( v ) )
		if ( ply:GetWeapon( tostring( v ) ) && ply:GetWeapon( tostring( v ) ):IsValid() ) then
		
			ply:GiveAmmo( ply:GetWeapon( tostring( v ) ):Clip1() * 3, ply:GetWeapon( tostring( v ) ):GetPrimaryAmmoType(), true )
		
		end
	
	end

end


-- Should the player play the death sound
function GM:PlayerDeathSound()

	return true

end


-- Called when the player attempts to suicide
function GM:CanPlayerSuicide( ply )

	-- Disable suicide
	return false

end


-- Player tries to toggle flashlight
function GM:PlayerSwitchFlashlight( ply, on )

	if ( on && ( ply:Team() != TEAM_SURVIVOR ) ) then return false end

	return ply:CanUseFlashlight()

end


-- Return a damage amount for fall damage
function GM:GetFallDamage( ply, speed )

	-- No damage
	return 0

end


-- Called when a player uses an act taunt
function GM:PlayerShouldTaunt( ply, id )

	-- Disable taunts
	return false

end


-- Called when a player wants to pick up an object
function GM:AllowPlayerPickup( ply, ent )

	-- Disable pickup
	return false

end
