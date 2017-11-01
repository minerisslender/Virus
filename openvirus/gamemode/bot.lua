-- Initialize bot stuff!

if ( SERVER ) then AddCSLuaFile() end


-- Create NextBot Player ConVars
ov_sv_bot_dumb = CreateConVar( "ov_sv_bot_dumb", "0", FCVAR_NOTIFY, "Bots won't shoot anything." )
ov_sv_bot_slower = CreateConVar( "ov_sv_bot_slower", "0", FCVAR_NOTIFY, "Bots run much more slower than normal." )
ov_sv_bot_stop = CreateConVar( "ov_sv_bot_stop", "0", FCVAR_NOTIFY, "Bots will stop in time." )


-- Create a NextBot Player
function OV_CREATEBOT( ply, cmd, args, argstring )

	if ( CLIENT ) then return end
	if ( game.IsDedicated() ) then return end
	if ( player.GetCount() >= game.MaxPlayers() ) then return end
	if ( !ply:IsAdmin() ) then return end

	player.CreateNextBot( argstring )

end
concommand.Add( "ov_bot_add", OV_CREATEBOT )


-- Create NextBot Players
function OV_CREATEBOTFILL( ply, cmd, args, argstring )

	if ( CLIENT ) then return end
	if ( game.IsDedicated() ) then return end
	if ( player.GetCount() >= game.MaxPlayers() ) then return end
	if ( !ply:IsAdmin() ) then return end

	for i = 1, ( game.MaxPlayers() - player.GetCount() ) do
	
		player.CreateNextBot( "Bot"..i )
	
	end

end
concommand.Add( "ov_bot_add_fill", OV_CREATEBOTFILL )


-- Infect all the bots
function OV_INFECTALLBOTS( ply, cmd, args, argstring )

	if ( CLIENT ) then return end
	if ( game.IsDedicated() ) then return end
	if ( !ply:IsAdmin() ) then return end

	for _, ply2 in pairs( player.GetBots() ) do
	
		ply2:InfectPlayer()
		ply2:Spawn()
	
	end

end
concommand.Add( "ov_bot_infect_all", OV_INFECTALLBOTS )


-- NextBot Player spawns
function BOT_PlayerSpawn( ply )

	if ( ply:IsBot() ) then
	
		ply.BotPlayerAttackSpeed = CurTime()
		ply.BotPlayerReactionSpeed = CurTime()
		ply.BotPlayerReactionSkill = math.Rand( 1, 2 )
		ply.BotPlayerSkill = math.random( 16, 32 )
		timer.Simple( 0.1, function() if ( ply && ply:IsValid() && ( ply:Team() == TEAM_SURVIVOR ) && ( #ply:GetWeapons() > 0 ) ) then ply.BotPlayerPreferredWeapon = table.Random( ply:GetWeapons() ) end end )
		ply.BotPlayerUseSLAM = tobool( math.random( 0, 1 ) )
		ply.BotPlayerUseSLAMTime = CurTime() + math.random( 4, 12 )
		ply.BotPlayerUsesAdrenaline = tobool( math.random( 0, 1 ) )
		ply.BotPlayerUseAdrenalineTime = CurTime()
	
		ply:SetAvoidPlayers( false )
	
		if ( ply.BotPlayerNav && ply.BotPlayerNav:IsValid() ) then
		
			ply.BotPlayerNav:SetPos( ply:GetPos() )
		
		end
	
	end

end
hook.Add( "PlayerSpawn", "BOT_PlayerSpawn", BOT_PlayerSpawn )


-- NextBot Player dies
function BOT_PlayerDeath( ply )

	if ( ply:IsBot() ) then
	
		timer.Simple( 4, function() if ( !OV_Game_EndRound && ply:IsValid() && !ply:Alive() ) then ply:Spawn() end end )
	
	end

end
hook.Add( "PlayerDeath", "BOT_PlayerDeath", BOT_PlayerDeath )


-- NextBot Player disconnects
function BOT_PlayerDisconnected( ply )

	if ( ply:IsBot() ) then
	
		if ( ply.BotPlayerNav && ply.BotPlayerNav:IsValid() ) then
		
			ply.BotPlayerNav:Remove()
		
		end
	
	end

end
hook.Add( "PlayerDisconnected", "BOT_PlayerDisconnected", BOT_PlayerDisconnected )


-- Entity takes damage
function BOT_EntityTakeDamage( ent )

	if ( ent:GetClass() == "ent_bot_navigation" ) then
	
		return true
	
	end

end
hook.Add( "EntityTakeDamage", "BOT_EntityTakeDamage", BOT_EntityTakeDamage )


-- Bot movement
function BOT_StartCommand( ply, ucmd )

	if ( ( OV_Game_PreRound || OV_Game_InRound ) && ply:IsValid() && ply:IsBot() && ply:Alive() ) then
	
		ucmd:ClearButtons()
	
		-- Stop in time
		if ( ov_sv_bot_stop:GetBool() ) then return end
	
		-- Bot uses Adrenaline
		if ( !ov_sv_bot_dumb:GetBool() && OV_Game_InRound && ( ply:Team() == TEAM_SURVIVOR ) && ply.BotPlayerUsesAdrenaline && ply:HasWeapon( "weapon_ov_adrenaline" ) ) then
		
			if ( timer.Exists( "OV_RoundTimer" ) && ( timer.TimeLeft( "OV_RoundTimer" ) <= 20 ) && ( ply.BotPlayerUseAdrenalineTime < CurTime() ) ) then
			
				ply:SelectWeapon( "weapon_ov_adrenaline" )
				ucmd:SetButtons( IN_ATTACK )
			
				ply.BotPlayerUseAdrenalineTime = CurTime() + 0.1
			
			end
		
			if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( ply:GetActiveWeapon():GetClass() == "weapon_ov_adrenaline" ) ) then return end
		
		end
	
		-- Bot uses SLAM
		if ( !ov_sv_bot_dumb:GetBool() && ( ply:Team() == TEAM_SURVIVOR ) && ply.BotPlayerUseSLAM && ply:HasWeapon( "weapon_ov_slam" ) ) then
		
			if ( ply.BotPlayerUseSLAMTime < CurTime() ) then
			
				ply:SelectWeapon( "weapon_ov_slam" )
				ucmd:SetButtons( IN_ATTACK )
			
				ply.BotPlayerUseSLAMTime = CurTime() + 0.5
			
			end
		
			if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( ply:GetActiveWeapon():GetClass() == "weapon_ov_slam" ) ) then return end
		
		end
	
		-- Infected inbound
		if ( !ov_sv_bot_dumb:GetBool() && ( ply:Team() == TEAM_SURVIVOR ) ) then
		
			local distancetable = {}
			for _, ply2 in pairs( team.GetPlayers( TEAM_INFECTED ) ) do
			
				if ( ply2:IsValid() && ply2:Alive() && ply2:Visible( ply ) && ( ply2:GetPos():Distance( ply:GetPos() ) < 1024 ) ) then
				
					table.insert( distancetable, ply:GetPos():Distance( ply2:GetPos() ) )
				
					if ( ( ply:GetPos():Distance( ply2:GetPos() ) == math.min( unpack( distancetable ) ) ) && ( ply.BotPlayerReactionSpeed < CurTime() ) ) then
					
						ply:SetEyeAngles( ( ( ply2:EyePos() - Vector( 0, 0, ply.BotPlayerSkill ) ) - ply:EyePos() ):Angle() )
					
						if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( ply:GetActiveWeapon().Primary.Automatic || ( ply.BotPlayerAttackSpeed < CurTime() ) ) ) then
						
							ucmd:SetButtons( IN_ATTACK )
						
							ply.BotPlayerAttackSpeed = CurTime() + 0.25
						
						end
					
					end
				
				end
			
			end
		
			-- Set our reaction time
			if ( #distancetable <= 0 ) then ply.BotPlayerReactionSpeed = CurTime() + ply.BotPlayerReactionSkill end
		
		end
	
		-- Switch preferred weapons
		if ( ply:Team() == TEAM_SURVIVOR ) then
		
			if ( ply.BotPlayerPreferredWeapon && ply.BotPlayerPreferredWeapon:IsValid() ) then
			
				if ( ( ply.BotPlayerPreferredWeapon:GetClass() != "weapon_ov_laserrifle" ) && ( ply.BotPlayerPreferredWeapon:Clip1() <= 0 ) && ( ply.BotPlayerPreferredWeapon:Ammo1() <= 0 ) ) then
				
					ply.BotPlayerPreferredWeapon = table.Random( ply:GetWeapons() )
				
					if ( ( ply.BotPlayerPreferredWeapon:GetClass() == "weapon_ov_slam" ) || ( ply.BotPlayerPreferredWeapon:GetClass() == "weapon_ov_adrenaline" ) ) then
					
						ply.BotPlayerPreferredWeapon = nil
					
					end
				
				end
			
			end
		
		end
	
		-- Switch to preferred weapon
		if ( ply:Team() == TEAM_SURVIVOR ) then
		
			if ( ply.BotPlayerPreferredWeapon && ply.BotPlayerPreferredWeapon:IsValid() && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( ply:GetActiveWeapon() != ply.BotPlayerPreferredWeapon ) ) then
			
				ply:SelectWeapon( ply.BotPlayerPreferredWeapon:GetClass() )
			
			end
		
		end
	
		-- Reload weapons
		if ( ply:Team() == TEAM_SURVIVOR ) then
		
			if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( ply:GetActiveWeapon():GetClass() != "weapon_ov_laserrifle" ) ) then
			
				if ( ply:GetActiveWeapon():Clip1() <= 0 ) then
				
					ucmd:SetButtons( IN_RELOAD )
				
				end
			
			end
		
		end
	
		-- Move towards the navigation
		if ( ply.BotPlayerNav && ply.BotPlayerNav:IsValid() && ( ply.BotPlayerNav:GetPos():Distance( ply:GetPos() ) >= 4 ) ) then
		
			ucmd:SetViewAngles( ( ply.BotPlayerNav:GetPos() - ply:GetPos() ):Angle() )
		
			-- Since NextBots do not angle themselves with SetViewAngles
			if ( OV_Game_PreRound || ( ply:Team() == TEAM_INFECTED ) ) then ply:SetEyeAngles( ( ply.BotPlayerNav:GetPos() - ply:GetPos() ):Angle() ) end
		
			ucmd:SetForwardMove( ply:GetWalkSpeed() )
		
		end
	
		-- Missing a navigation entity
		if ( !ply.BotPlayerNav || !ply.BotPlayerNav:IsValid() ) then
		
			ply.BotPlayerNav = ents.Create( "ent_bot_navigation" )
			ply.BotPlayerNav:SetPos( ply:GetPos() )
			ply.BotPlayerNav:SetOwner( ply )
			ply.BotPlayerNav:Spawn()
			ply.BotPlayerNav:Activate()
		
		end
	
	end

end
hook.Add( "StartCommand", "BOT_StartCommand", BOT_StartCommand )
