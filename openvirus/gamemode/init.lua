-- Initialize the gamemode!

include( "shared.lua" )
include( "player.lua" )

AddCSLuaFile( "cl_scoreboard.lua" )


-- Functions down here
-- Called when the game is initialized
function GM:Initialize()

	-- Global variables
	OV_Game_WaitingForPlayers = true
	OV_Game_PreRound = false
	OV_Game_InRound = false
	OV_Game_LastSurvivor = false
	OV_Game_EndRound = false
	OV_Game_Round = 0
	OV_Game_MaxRounds = 10
	OV_Game_MinimumPlayers = 4

	OV_Game_MainRoundTimerCount = 90

	OV_Game_WeaponLoadout = {}
	OV_Game_WeaponLoadout_Primary = {}
	OV_Game_WeaponLoadout_Secondary = {}
	OV_Game_WeaponLoadout_Shotguns = {}
	OV_Game_WeaponLoadout_RemoveSelected = "UNKNOWN"

	OV_Game_LastRandomChosenInfected = "STEAM_ID_PENDING"

	-- Network Strings
	util.AddNetworkString( "OV_UpdateRoundStatus" )
	util.AddNetworkString( "OV_SendTimerCount" )
	util.AddNetworkString( "OV_SendDamageValue" )
	util.AddNetworkString( "OV_ClientsideInfect" )
	util.AddNetworkString( "OV_SendInfoText" )
	util.AddNetworkString( "OV_DoSpawnEffect" )
	util.AddNetworkString( "OV_SetMusic" )
	util.AddNetworkString( "OV_CStrikeValidation" )
	util.AddNetworkString( "OV_ClientInitializedMusic" )
	util.AddNetworkString( "OV_RadarEnabled" )

	-- Set the default deploy speed to 1
	game.ConsoleCommand( "sv_defaultdeployspeed 1\n" )

	-- Set alltalk to 1
	game.ConsoleCommand( "sv_alltalk 1\n" )

	-- ConVars
	ov_sv_onlyonesurvivor = CreateConVar( "ov_sv_onlyonesurvivor", "0", FCVAR_NOTIFY, "Only One Survivor gametype. One survivor is set to dominate the infected until time runs out." )
	ov_sv_infection_serverside_only = CreateConVar( "ov_sv_infection_serverside_only", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Disable client-sided infecting and forces server-side infecting instead. Doesn't help people with lag problems." )
	ov_sv_infection_clientside_valid_distance = CreateConVar( "ov_sv_infection_clientside_valid_distance", "256", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "With client-side infection, we make sure the distance between players is considered valid. This can prevent client-side scripts from being able to cheat." )
	ov_sv_infected_blood = CreateConVar( "ov_sv_infected_blood", "1", FCVAR_ARCHIVE, "Enable the infected blood effects." )
	ov_sv_infected_specific_model = CreateConVar( "ov_sv_infected_specific_model", "1", FCVAR_NOTIFY, "Force infected players to have a specific model with the GAMEMODE.OV_Infected_Model function." )
	ov_sv_survivor_setup_hands = CreateConVar( "ov_sv_survivor_setup_hands", "1", FCVAR_ARCHIVE, "Call SetupHands for survivors. Disabling this means no hands for weapon viewmodels." )
	ov_sv_survivor_css_hands = CreateConVar( "ov_sv_survivor_css_hands", "1", FCVAR_ARCHIVE, "Hands will be forced as CS:S hands for survivors." )
	ov_sv_allow_non_css_owners = CreateConVar( "ov_sv_allow_non_css_owners", "1", FCVAR_NOTIFY, "Players who don't own CS:S will be allowed to play." )
	ov_sv_enable_player_radar = CreateConVar( "ov_sv_enable_player_radar", "1", FCVAR_NOTIFY, "Players can see the radar." )

	-- ConCommands
	concommand.Add( "invwep", function( ply, cmd, args, argstring ) if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_SURVIVOR ) ) then ply:SelectWeapon( argstring ) end end )
	concommand.Add( "ov_net_update", function( ply )
	
		if ( OV_Game_InRound ) then
		
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
					net.WriteInt( timer.TimeLeft( "OV_RoundTimer" ), 16 )
				net.Broadcast()
			
			end
		
			net.Start( "OV_RadarEnabled" )
				net.WriteBool( ov_sv_enable_player_radar:GetBool() )
			net.Send( ply )
		
		end
	
	end )

end


-- Can players hear another player using voice
function GM:PlayerCanHearPlayersVoice( listener, talker )

	return true

end


-- Client has sent us information that they want to infect someone
function OV_ClientsideInfect( len, ply )

	if ( ov_sv_infection_serverside_only:GetBool() ) then return end
	if ( !OV_Game_InRound ) then return end

	local target_ply = net.ReadEntity()
	if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_INFECTED ) && ply:GetInfectionStatus() && target_ply && target_ply:IsValid() && target_ply:IsPlayer() && target_ply:Alive() && ( target_ply:Team() == TEAM_SURVIVOR ) ) then
	
		-- Validate the distance between the players
		if ( ply:GetPos():Distance( target_ply:GetPos() ) <= ov_sv_infection_clientside_valid_distance:GetFloat() ) then
		
			target_ply:InfectPlayer( ply )
		
		end
	
	end

end
net.Receive( "OV_ClientsideInfect", OV_ClientsideInfect )


-- Client has sent us information about CStrike
function OV_CStrikeValidation( len, ply )

	if ( ov_sv_allow_non_css_owners:GetBool() || net.ReadBool() ) then
	
		ply.excludeFromGame = false
	
		ply:ChatPrint( "Welcome to open Virus!" )
		ply:ChatPrint( "This is not affiliated with PixelTail." )
		ply:ChatPrint( "Version: "..GAMEMODE.Version )
	
	else
	
		ply.excludeFromGame = true
		ply:Spawn()
	
		ply:ChatPrint( "We recommend you buy Counter-Strike: Source to play this gamemode." )
		ply:ChatPrint( "OR, you can buy Tower Unite to play the official Virus." )
	
	end

end
net.Receive( "OV_CStrikeValidation", OV_CStrikeValidation )


-- Client has initialized music
function OV_ClientInitializedMusic( len, ply )

	if ( !OV_Game_EndRound && ply && ply:IsValid() ) then
	
		OV_SetMusic( 0, ply )
	
		if ( OV_Game_WaitingForPlayers ) then
		
			OV_SetMusic( 1, ply )
		
		elseif ( OV_Game_PreRound ) then
		
			OV_SetMusic( 2, ply )
		
		elseif ( OV_Game_InRound ) then
		
			if ( OV_Game_LastSurvivor ) then
			
				OV_SetMusic( 4, ply )
			
			else
			
				OV_SetMusic( 3, ply )
			
			end
		
		end
	
	end

end
net.Receive( "OV_ClientInitializedMusic", OV_ClientInitializedMusic )


-- Global function to set music
function OV_SetMusic( int, ply )

	-- Send to a specific player instead
	if ( ply && ply:IsValid() && ply:IsPlayer() ) then
	
		net.Start( "OV_SetMusic" )
			net.WriteInt( int, 4 )
		net.Send( ply )
	
		return
	
	end

	net.Start( "OV_SetMusic" )
		net.WriteInt( int, 4 )
	net.Broadcast()

end


-- Called every frame
function GM:Think()

	-- Infected cannot infect players instantly when they spawn
	if ( OV_Game_InRound || OV_Game_EndRound ) then
	
		for _, ply in pairs( team.GetPlayers( TEAM_INFECTED ) ) do
		
			if ( ply:IsValid() && ply:Alive() && !ply:GetInfectionStatus() && ( ply.timeInfectionStatus < CurTime() ) ) then
				
				ply:SetInfectionStatus( 1 )
				
			end
		
		end
	
	end

	-- Player adrenaline status needs to run out eventually
	if ( OV_Game_PreRound || OV_Game_InRound || OV_Game_EndRound ) then
	
		for _, ply in pairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( ply:IsValid() && ply:GetAdrenalineStatus() && ( ply.timeAdrenalineStatus < CurTime() ) ) then
			
				ply:SetAdrenalineStatus( 0 )
			
			end
		
		end
	
	end

	-- Enraged players must be cancelled
	if ( ( OV_Game_InRound || OV_Game_EndRound ) && ( team.NumPlayers( TEAM_INFECTED ) > 1 ) ) then
	
		for _, ply in pairs( team.GetPlayers( TEAM_INFECTED ) ) do
		
			if ( ply:IsValid() && ply:GetEnragedStatus() ) then
			
				ply:SetEnragedStatus( 0 )
			
			end
		
		end
	
	end

	-- Last survivor engaged
	if ( OV_Game_InRound && !OV_Game_LastSurvivor && ( team.NumPlayers( TEAM_SURVIVOR ) < 2 ) ) then
	
		for _, ply in pairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( ply:IsValid() && ply:Alive() ) then
			
				OV_Game_LastSurvivor = true
			
				OV_SetMusic( 0 )
			
				net.Start( "OV_SendInfoText" )
					net.WriteString( string.upper( ply:Name() ).." IS THE LAST SURVIVOR" )
					net.WriteColor( Color( 255, 255, 255 ) )
					net.WriteInt( 5, 4 )
				net.Broadcast()
			
				OV_SetMusic( 4 )
				BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_lastchance.wav\" )" )
			
			end
		
		end
	
	end

	-- Bots do not have clientside infection check or we are forcing serverside infection
	if ( OV_Game_InRound ) then
	
		if ( ( #player.GetBots() > 0 ) || ov_sv_infection_serverside_only:GetBool() ) then
		
			for _, ply in pairs( player.GetAll() ) do
			
				if ( ply:IsValid() && ( ply:IsBot() || ov_sv_infection_serverside_only:GetBool() ) && ply:Alive() && ( ply:Team() == TEAM_INFECTED ) && ply:GetInfectionStatus() ) then
				
					for _, ent in pairs( ents.FindInSphere( ply:EyePos() - Vector( 0, 0, 16 ), 8 ) ) do
					
						if ( ent:IsValid() && ent:IsPlayer() && ( ent:Health() > 0 ) && ( ent:Team() == TEAM_SURVIVOR ) ) then
						
							ent:InfectPlayer( ply )
						
						end
					
					end
				
				end
			
			end
		
		end
	
	end

	-- Select a random person to be infected
	if ( OV_Game_InRound && ( ( ov_sv_onlyonesurvivor:GetBool() && ( team.NumPlayers( TEAM_SURVIVOR ) > 1 ) || ( team.NumPlayers( TEAM_INFECTED ) == 0 ) ) ) ) then
	
		for _, ply in pairs( team.GetPlayers( TEAM_SURVIVOR ) ) do
		
			if ( ( ( ov_sv_onlyonesurvivor:GetBool() && ( team.NumPlayers( TEAM_SURVIVOR ) > 1 ) ) || ( team.NumPlayers( TEAM_INFECTED ) == 0 ) ) && ply:IsValid() && ( ply:IsBot() || ( ply:SteamID() != OV_Game_LastRandomChosenInfected ) ) ) then
			
				if ( math.random( 1, team.NumPlayers( TEAM_SURVIVOR ) * 2 ) == ( team.NumPlayers( TEAM_SURVIVOR ) * 2 ) ) then
				
					ply:InfectPlayer()
				
					if ( team.NumPlayers( TEAM_INFECTED ) <= 1 ) then BroadcastLua( "surface.PlaySound( \"openvirus/effects/ov_stinger.wav\" )" ) end
				
					OV_Game_LastRandomChosenInfected = ply:SteamID()
				
				end
			
			end
		
		end
	
	end

end


-- Called when the player is hurt
function GM:PlayerHurt( ply, attacker, health, dmg )

	-- Send damage values to the client
	if ( attacker:IsValid() && attacker:IsPlayer() && ( attacker:Health() > 0 ) && ( attacker:Team() == TEAM_SURVIVOR ) ) then
	
		net.Start( "OV_SendDamageValue" )
			net.WriteInt( dmg, 16 )
			net.WriteVector( ply:LocalToWorld( ply:OBBCenter() + Vector( 0, 0, 32 ) ) )
		net.Send( attacker )
	
		attacker:SendLua( "surface.PlaySound( \"buttons/blip1.wav\" )" )
	
	end

	-- Infected health is shown briefly
	if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_INFECTED ) ) then
	
		ply:SetNWInt( "InfectedLastHurt", CurTime() + 4 )
	
	end

	-- Infected blood effects
	if ( ov_sv_infected_blood:GetBool() ) then
	
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin( ply:LocalToWorld( ply:OBBCenter() ) )
		util.Effect( "infectedblood", bloodeffect )
	
	end

end


-- 4 players or over this should begin
function GM:BeginWaitingSession()

	net.Start( "OV_UpdateRoundStatus" )
		net.WriteBool( OV_Game_WaitingForPlayers )
		net.WriteBool( OV_Game_PreRound )
		net.WriteBool( OV_Game_InRound )
		net.WriteBool( OV_Game_EndRound )
		net.WriteInt( OV_Game_Round, 8 )
		net.WriteInt( OV_Game_MaxRounds, 8 )
	net.Broadcast()

	timer.Create( "OV_RoundTimer", 15, 1, function() GAMEMODE:BeginPreRound() end )

	net.Start( "OV_SendTimerCount" )
		net.WriteInt( timer.TimeLeft( "OV_RoundTimer" ), 16 )
	net.Broadcast()

	-- Start some music
	OV_SetMusic( 1 )

end


-- The PreRound moment before we start the actual game
function GM:BeginPreRound()

	-- Stop the music
	OV_SetMusic( 0 )

	-- Add to the round counter
	OV_Game_Round = OV_Game_Round + 1

	-- Set up a new set of weapons for players
	OV_Game_WeaponLoadout = {
		"weapon_ov_m3",
		"weapon_ov_pistol",
		"weapon_ov_flak",
		"weapon_ov_dualpistol",
		"weapon_ov_laserpistol",
		"weapon_ov_silencedpistol",
		"weapon_ov_p90",
		"weapon_ov_laserrifle",
		"weapon_ov_xm1014",
		"weapon_ov_mp5",
		"weapon_ov_sniper",
		"weapon_ov_slam",
		"weapon_ov_adrenaline"
	}

	-- List primary weapons
	OV_Game_WeaponLoadout_Primary = {
		"weapon_ov_pistol",
		"weapon_ov_dualpistol",
		"weapon_ov_laserpistol",
		"weapon_ov_silencedpistol"
	}

	-- List secondary weapons
	OV_Game_WeaponLoadout_Secondary = {
		"weapon_ov_p90",
		"weapon_ov_laserrifle",
		"weapon_ov_mp5"
	}

	-- List shotgun weapons
	OV_Game_WeaponLoadout_Shotguns = {
		"weapon_ov_m3",
		"weapon_ov_xm1014"
	}

	-- Remove some primary weapons
	for removenum = 1, ( #OV_Game_WeaponLoadout_Primary - 2 ) do
	
		OV_Game_WeaponLoadout_RemoveSelected = table.Random( OV_Game_WeaponLoadout_Primary )
		table.RemoveByValue( OV_Game_WeaponLoadout, OV_Game_WeaponLoadout_RemoveSelected )
		table.RemoveByValue( OV_Game_WeaponLoadout_Primary, OV_Game_WeaponLoadout_RemoveSelected )
	
	end

	-- Remove some secondary weapons
	for removenum = 1, ( #OV_Game_WeaponLoadout_Secondary - math.random( 1, 2 ) ) do
	
		OV_Game_WeaponLoadout_RemoveSelected = table.Random( OV_Game_WeaponLoadout_Secondary )
		table.RemoveByValue( OV_Game_WeaponLoadout, OV_Game_WeaponLoadout_RemoveSelected )
		table.RemoveByValue( OV_Game_WeaponLoadout_Secondary, OV_Game_WeaponLoadout_RemoveSelected )
	
	end

	-- Remove some shotguns
	for removenum = 1, ( #OV_Game_WeaponLoadout_Shotguns - math.random( 0, 1 ) ) do
	
		OV_Game_WeaponLoadout_RemoveSelected = table.Random( OV_Game_WeaponLoadout_Shotguns )
		table.RemoveByValue( OV_Game_WeaponLoadout, OV_Game_WeaponLoadout_RemoveSelected )
		table.RemoveByValue( OV_Game_WeaponLoadout_Shotguns, OV_Game_WeaponLoadout_RemoveSelected )
	
	end

	-- Random special weapons
	if ( math.random( 1, 6 ) > 1 ) then table.RemoveByValue( OV_Game_WeaponLoadout, "weapon_ov_flak" ) end
	if ( table.HasValue( OV_Game_WeaponLoadout, "weapon_ov_flak" ) || ( math.random( 1, 8 ) > 1 ) ) then table.RemoveByValue( OV_Game_WeaponLoadout, "weapon_ov_sniper" ) end

	-- Here we will clean up the map
	game.CleanUpMap()

	OV_Game_WaitingForPlayers = false
	OV_Game_PreRound = true
	OV_Game_InRound = false
	OV_Game_LastSurvivor = false
	OV_Game_EndRound = false

	net.Start( "OV_UpdateRoundStatus" )
		net.WriteBool( OV_Game_WaitingForPlayers )
		net.WriteBool( OV_Game_PreRound )
		net.WriteBool( OV_Game_InRound )
		net.WriteBool( OV_Game_EndRound )
		net.WriteInt( OV_Game_Round, 8 )
		net.WriteInt( OV_Game_MaxRounds, 8 )
	net.Broadcast()

	timer.Create( "OV_RoundTimer", math.random( 20, 25 ), 1, function() GAMEMODE:BeginMainRound() end )

	-- Close Scoreboard for players
	BroadcastLua( "GAMEMODE:ScoreboardHide()" )

	-- Respawn all players
	for _, ply in pairs( player.GetAll() ) do
	
		ply:Freeze( false )
	
		ply:SetTeam( TEAM_SURVIVOR )
		ply:SetColor( Color( 255, 255, 255 ) )
		ply:SetEnragedStatus( 0 )
		ply:SetInfectionStatus( 0 )
		ply:SetAdrenalineStatus( 0 )
	
		ply:SetFrags( 0 )
		ply:SetDeaths( 0 )
	
		ply:RemoveAllItems()
	
		ply:Spawn()
	
		ply:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.25, 0.75 )
	
	end

	-- Indicate that the infection is about to spread
	net.Start( "OV_SendInfoText" )
		net.WriteString( "THE INFECTION IS ABOUT TO SPREAD" )
		net.WriteColor( Color( 255, 255, 255 ) )
		net.WriteInt( 5, 4 )
	net.Broadcast()

	-- Indicate that this is the last round
	if ( OV_Game_Round >= OV_Game_MaxRounds ) then
	
		net.Start( "OV_SendInfoText" )
			net.WriteString( "THIS IS THE LAST ROUND" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
	end

	-- Start some music
	OV_SetMusic( 2 )

end


-- Begin the main Round
function GM:BeginMainRound()

	-- Do not begin the main round if we are below minimum player requirement
	if ( player.GetCount() < OV_Game_MinimumPlayers ) then
	
		timer.Create( "OV_RoundTimer", 1, 1, function() GAMEMODE:BeginMainRound() end )
		return
	
	end

	-- Stop music
	OV_SetMusic( 0 )

	OV_Game_PreRound = false
	OV_Game_InRound = true

	net.Start( "OV_UpdateRoundStatus" )
		net.WriteBool( OV_Game_WaitingForPlayers )
		net.WriteBool( OV_Game_PreRound )
		net.WriteBool( OV_Game_InRound )
		net.WriteBool( OV_Game_EndRound )
		net.WriteInt( OV_Game_Round, 8 )
		net.WriteInt( OV_Game_MaxRounds, 8 )
	net.Broadcast()

	timer.Create( "OV_RoundTimer", OV_Game_MainRoundTimerCount, 1, function() GAMEMODE:EndMainRound() end )

	-- Only One Survivor
	if ( ov_sv_onlyonesurvivor:GetBool() && timer.Exists( "OV_RoundTimer" ) ) then
	
		timer.Adjust( "OV_RoundTimer", OV_Game_MainRoundTimerCount / 3, 1, function() GAMEMODE:EndMainRound() end )
	
	end

	net.Start( "OV_SendTimerCount" )
		net.WriteInt( timer.TimeLeft( "OV_RoundTimer" ), 16 )
	net.Broadcast()

	-- Start some music
	OV_SetMusic( 3 )

	-- Update radar visibility
	net.Start( "OV_RadarEnabled" )
		net.WriteBool( ov_sv_enable_player_radar:GetBool() )
	net.Broadcast()

	-- Allow for events to happen after the round has started
	hook.Call( "PostBeginMainRound", GAMEMODE )

end


-- End the main Round
function GM:EndMainRound()

	-- Stop music
	OV_SetMusic( 0 )

	for _, ply in pairs( player.GetAll() ) do
	
		ply:Freeze( true )
		if ( ply:GetAdrenalineStatus() ) then ply:SetAdrenalineStatus( 0 ) end
	
	end

	OV_Game_InRound = false
	OV_Game_EndRound = true

	net.Start( "OV_UpdateRoundStatus" )
		net.WriteBool( OV_Game_WaitingForPlayers )
		net.WriteBool( OV_Game_PreRound )
		net.WriteBool( OV_Game_InRound )
		net.WriteBool( OV_Game_EndRound )
		net.WriteInt( OV_Game_Round, 8 )
		net.WriteInt( OV_Game_MaxRounds, 8 )
	net.Broadcast()

	timer.Create( "OV_RoundTimer", 15, 1, function() GAMEMODE:BeginPreRound() end )

	net.Start( "OV_SendTimerCount" )
		net.WriteInt( timer.TimeLeft( "OV_RoundTimer" ), 16 )
	net.Broadcast()

	if ( team.NumPlayers( TEAM_SURVIVOR ) > 0 ) then
	
		net.Start( "OV_SendInfoText" )
			net.WriteString( "THE SURVIVORS WIN" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
		OV_SetMusic( 6 )
		BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_survivorswin.wav\" )" )
	
	else
	
		net.Start( "OV_SendInfoText" )
			net.WriteString( "THE INFECTION HAS SPREAD" )
			net.WriteColor( Color( 255, 255, 255 ) )
			net.WriteInt( 5, 4 )
		net.Broadcast()
	
		OV_SetMusic( 5 )
		BroadcastLua( "surface.PlaySound( \"openvirus/vo/ov_vo_infectedwin.wav\" )" )
	
	end

	-- Reached the max amount of rounds
	if ( OV_Game_Round >= OV_Game_MaxRounds ) then
	
		-- Remove the RoundTimer
		if ( timer.Exists( "OV_RoundTimer" ) ) then
		
			timer.Remove( "OV_RoundTimer" )
		
		end
	
		timer.Simple( 20, function() game.LoadNextMap() end )
	
	end

	-- Open Scoreboard for players
	timer.Simple( 2, function() BroadcastLua( "GAMEMODE:ScoreboardShow()" ) end )

	-- Allow for events to happen after the round has ended
	hook.Call( "PostEndMainRound", GAMEMODE )

end


-- During this phase we check for 4 players until we continue
function OV_Game_WaitingForPlayers_GetPlayerCount()

	-- At 4 players or over we should start
	if ( player.GetCount() >= OV_Game_MinimumPlayers ) then
	
		GAMEMODE:BeginWaitingSession()
		timer.Remove( "OV_Game_WaitingForPlayers_GetPlayerCount" )
	
	end

end
timer.Create( "OV_Game_WaitingForPlayers_GetPlayerCount", 1, 0, OV_Game_WaitingForPlayers_GetPlayerCount )


-- Show Help
function GM:ShowHelp( ply )

	ply:SendLua( "GAMEMODE:ShowHelp()" )

end
