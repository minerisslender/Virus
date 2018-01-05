-- Initialize the gamemode!

include( "player_class/player_virus.lua" )
include( "player_meta.lua" )
include( "ammo.lua" )

-- Custom map-specific hooking stuff
if ( file.Exists( "openvirus/gamemode/ov_maplua/"..game.GetMap()..".lua", "LUA" ) ) then

	include( "ov_maplua/"..game.GetMap()..".lua" )

end

if ( SERVER ) then AddCSLuaFile() end


-- Functions down here
-- Name, Author, Email and Website
GM.Name     =   "open Virus"
GM.Author   =   "daunknownman2010"
GM.Email    =   "N/A"
GM.Website  =   "N/A"
GM.Version  =   "rev28 (Public Alpha)"


-- Some global stuff here
GM.OV_Survivor_Speed = 300
GM.OV_Survivor_AdrenSpeed = 440
GM.OV_Infected_Health = 100
GM.OV_Infected_EnrageHealth = 400
GM.OV_Infected_Speed = 380
GM.OV_Infected_EnrageSpeed = 460
GM.OV_Infected_Model = "models/player/corpse1.mdl"


-- Should the player take damage
function GM:PlayerShouldTakeDamage( ply, attacker )

	-- Block damaging players
	if ( IsValid( ply ) && ( ply:Team() == TEAM_SURVIVOR ) && IsValid( attacker ) && ( attacker:GetClass() != "trigger_hurt" ) ) then
	
		return false
	
	end

	-- Players cannot kill teammates
	if ( IsValid( ply ) && IsValid( attacker ) && attacker:IsPlayer() && ( ply:Team() == attacker:Team() ) ) then
	
		return false
	
	end

	-- One infected player cannot be damaged in non infection mode
	if ( !GetGlobalBool( "OV_Game_PreventEnraged" ) && IsValid( ply ) && ( ply:Team() == TEAM_INFECTED ) && ( ply:Deaths() > 2 ) && !ply:GetInfectionStatus() ) then
	
		return false
	
	end

	return true

end


-- Scale the player damage
function GM:ScalePlayerDamage( ply, hitgroup, info )

	-- Scale stuff
	if ( hitgroup == HITGROUP_HEAD ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) > 6 ) then
		
			info:ScaleDamage( 1 )
		
		else
		
			info:ScaleDamage( 2 )
		
		end
	
	elseif ( hitgroup == HITGROUP_LEFTLEG ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) > 6 ) then
		
			info:ScaleDamage( 0.25 )
		
		else
		
			info:ScaleDamage( 0.5 )
		
		end
	
	elseif ( hitgroup == HITGROUP_RIGHTLEG ) then
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) > 6 ) then
		
			info:ScaleDamage( 0.25 )
		
		else
		
			info:ScaleDamage( 0.5 )
		
		end
	
	else
	
		if ( team.NumPlayers( TEAM_SURVIVOR ) > 6 ) then
		
			info:ScaleDamage( 0.5 )
		
		else
		
			info:ScaleDamage( 1 )
		
		end
	
	end

end


-- Create our teams here
function GM:CreateTeams()

	TEAM_SPECTATOR = 0
	team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 0, 0, 0 ) )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

	TEAM_SURVIVOR = 1
	team.SetUp( TEAM_SURVIVOR, "Survivor", Color( 255, 255, 255 ) )
	team.SetSpawnPoint( TEAM_SURVIVOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

	TEAM_INFECTED = 2
	team.SetUp( TEAM_INFECTED, "Infected", Color( 0, 255, 0 ) )
	team.SetSpawnPoint( TEAM_SURVIVOR, { "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist" } )

end


-- Called when two entities with custom collision check collide
function GM:ShouldCollide( ent1, ent2 )

	-- PvP Collision rule
	if ( ( IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && ( ent1:Team() == ent2:Team() ) ) || ( IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && ( ent2:Team() == ent1:Team() ) ) ) then
	
		return false
	
	end

	-- SLAMs should not collide with players
	if ( ( IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && IsValid( ent2 ) && ( ent2:GetClass() == "ent_ov_slam" ) ) || ( IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && IsValid( ent1 ) && ( ent1:GetClass() == "ent_ov_slam" ) ) ) then
	
		return false
	
	end

	-- Bot navigation entity
	if ( ( IsValid( ent1 ) && ent1:IsPlayer() && ent1:Alive() && IsValid( ent2 ) && ( ent2:GetClass() == "ent_bot_navigation" ) ) || ( IsValid( ent2 ) && ent2:IsPlayer() && ent2:Alive() && IsValid( ent1 ) && ( ent1:GetClass() == "ent_bot_navigation" ) ) ) then
	
		return false
	
	end

	return true

end


-- This is used to prevent certain move commands from working
function GM:StartCommand( ply, ucmd )

	local blocked_keys = { IN_JUMP, IN_DUCK, IN_SPEED, IN_WALK, IN_ZOOM }

	-- Block the keys
	for k, v in pairs( blocked_keys ) do
	
		if ( ucmd:KeyDown( v ) ) then
		
			ucmd:RemoveKey( v )
		
		end
	
	end

end
