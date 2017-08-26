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
GM.Version  =   "rev15 (Public Alpha)"


-- Some global stuff here
GM.OV_Survivor_Speed = 300
GM.OV_Survivor_AdrenSpeed = 425
GM.OV_Infected_Health = 100
GM.OV_Infected_EnrageHealth = 500
GM.OV_Infected_Speed = 350
GM.OV_Infected_EnrageSpeed = 450
GM.OV_Infected_Model = "models/player/corpse1.mdl"


-- Should the player take damage
function GM:PlayerShouldTakeDamage( ply, attacker )

    -- Block damaging players
    if ( ply:IsValid() && ( ply:Team() == TEAM_SURVIVOR ) && attacker:IsValid() && ( attacker:GetClass() != "trigger_hurt" ) ) then
    
        return false
    
    end

	-- One infected player cannot be damaged in non infection mode
	if ( ( team.NumPlayers( TEAM_INFECTED ) < 2 ) && ply:IsValid() && ( ply:Team() == TEAM_INFECTED ) && ( ply:Deaths() > 2 ) && !ply:GetInfectionStatus() ) then
	
		return false
	
	end

    return true

end


-- Scale the player damage
function GM:ScalePlayerDamage( ply, hitgroup, info )

	if ( hitgroup == HITGROUP_HEAD ) then
	
		info:ScaleDamage( 2 )
	
	elseif ( hitgroup == HITGROUP_LEFTLEG ) then
	
		info:ScaleDamage( 0.75 )
	
	elseif ( hitgroup == HITGROUP_RIGHTLEG ) then
	
		info:ScaleDamage( 0.75 )
	
	else
	
		info:ScaleDamage( 1 )
	
	end

end


-- Create our teams here
function GM:CreateTeams()

    TEAM_SPECTATOR = 0
    team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 0, 0, 0 ) )
    team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_terrorist" } )

    TEAM_SURVIVOR = 1
    team.SetUp( TEAM_SURVIVOR, "Survivor", Color( 255, 255, 255 ) )
    team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_terrorist" } )

    TEAM_INFECTED = 2
    team.SetUp( TEAM_INFECTED, "Infected", Color( 0, 255, 0 ) )
    team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_terrorist" } )

end


-- Called when two entities with custom collision check collide
function GM:ShouldCollide( ent1, ent2 )

	-- PvP Collision rule
	if ( ( ent1:IsValid() && ent1:IsPlayer() && ent1:Alive() && ent2:IsValid() && ent2:IsPlayer() && ent2:Alive() && ( ent1:Team() == ent2:Team() ) ) || ( ent2:IsValid() && ent2:IsPlayer() && ent2:Alive() && ent1:IsValid() && ent1:IsPlayer() && ent1:Alive() && ( ent2:Team() == ent1:Team() ) ) ) then
	
		return false
	
	end

	-- Infected blood should not collide with people
	if ( ( ent1:IsValid() && ent1:IsPlayer() && ent1:Alive() && ent2:IsValid() && ( ent2:GetClass() == "ent_ov_infectedblood" ) ) || ( ent2:IsValid() && ent2:IsPlayer() && ent2:Alive() && ent1:IsValid() && ( ent1:GetClass() == "ent_ov_infectedblood" ) ) ) then
	
		return false
	
	end

	-- Bot navigation entity
	if ( ( ent1:IsValid() && ent1:IsPlayer() && ent1:Alive() && ent2:IsValid() && ( ent2:GetClass() == "ent_bot_navigation" ) ) || ( ent2:IsValid() && ent2:IsPlayer() && ent2:Alive() && ent1:IsValid() && ( ent1:GetClass() == "ent_bot_navigation" ) ) ) then
	
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
