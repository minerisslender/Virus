-- Initialize the gamemode!

include( "shared.lua" )
include( "cl_scoreboard.lua" )


-- Functions down here
-- Called when the game is initialized
function GM:Initialize()

    -- Hide scoreboard
    GAMEMODE.ShowScoreboard = false

    -- Global variables
    OV_InformationText = {}
	OV_CountdownText = {}
    OV_DamageValues = {}
    OV_WeaponSelectionTable = {}
    OV_WeaponSelectionName = ""
    OV_WeaponSelectionNameTime = 0

    OV_Game_WaitingForPlayers = true
    OV_Game_PreRound = false
    OV_Game_InRound = false
    OV_Game_EndRound = false
    OV_Game_Round = 0
    OV_Game_MaxRounds = 0

	-- Radar player point
    OV_Material_Radar = Material( "openvirus/radar.vmt" )
    OV_Material_RadarPoint = Material( "openvirus/radar_point.vmt" )

    -- Create this for the infected flame
    OV_Material_InfectedFlameFrameUpdate = 0
    OV_Material_InfectedFlameFrames = {}
    OV_Material_InfectedFlameFrames[ 1 ] = CreateMaterial( "infectedflame1", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )
    OV_Material_InfectedFlameFrames[ 2 ] = CreateMaterial( "infectedflame2", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "1" } )
    OV_Material_InfectedFlameFrames[ 3 ] = CreateMaterial( "infectedflame3", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "2" } )
    OV_Material_InfectedFlameFrames[ 4 ] = CreateMaterial( "infectedflame4", "UnlitGeneric", { [ "$basetexture" ] = "sprites/floorfire4_", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1", [ "$frame" ] = "3" } )
    OV_Material_InfectedFlame = OV_Material_InfectedFlameFrames[ 1 ]
    OV_Material_InfectedFlameFrameInt = 1

    -- Spawn effect table
    OV_Material_SpawnEffectTable = {}
    OV_Material_SpawnEffectSprite = CreateMaterial( "spawneffect", "UnlitGeneric", { [ "$basetexture" ] = "sprites/blueglow1", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

	-- Render SLAM sprite
    OV_Material_SLAMSprite = CreateMaterial( "slamsprite", "UnlitGeneric", { [ "$basetexture" ] = "sprites/laserdot", [ "$vertexcolor" ] = "1", [ "$vertexalpha" ] = "1", [ "$additive" ] = "1", [ "$nocull" ] = "1" } )

    -- Sound and music stuff
    OV_Sounds_WaitingForPlayers = {}
    OV_Sounds_PreRound = {}
    OV_Sounds_InRound = {}
    OV_Sounds_LastSurvivor = {}
	OV_Sounds_InfectedWin = {}
	OV_Sounds_SurvivorsWin = {}

    -- Create some Client ConVars
    ov_cl_hl2_wpn_selection = CreateClientConVar( "ov_cl_hl2_wpn_selection", "1", true, false )
    ov_cl_survivor_thirdperson = CreateClientConVar( "ov_cl_survivor_thirdperson", "0", false, false )
    ov_cl_survivor_thirdperson_right = CreateClientConVar( "ov_cl_survivor_thirdperson_right", "1", false, false )
    ov_cl_screenspace_effects = CreateClientConVar( "ov_cl_screenspace_effects", "1", true, false )
    ov_cl_sound_dsp_effects = CreateClientConVar( "ov_cl_sound_dsp_effects", "1", true, false )
    ov_cl_survivor_geigercounter = CreateClientConVar( "ov_cl_survivor_geigercounter", "1", true, false )
    ov_cl_hud_force_hiscale = CreateClientConVar( "ov_cl_hud_force_hiscale", "0", true, false )
    ov_cl_camera_bob = CreateClientConVar( "ov_cl_camera_bob", "1", true, false )
    ov_cl_round_music = CreateClientConVar( "ov_cl_round_music", "1", true, false )

	-- ConCommands
	concommand.Add( "ov_net_update", function() return end )

	-- Display the help menu if we a missing this thing
	if ( !file.Exists( "openvirus", "DATA" ) ) then
	
		file.CreateDir( "openvirus" )
	
	end

	if ( !file.Exists( "openvirus/client", "DATA" ) ) then
	
		file.CreateDir( "openvirus/client" )
	
	end

	if ( !file.Exists( "openvirus/client/seen_help_menu.txt", "DATA" ) ) then
	
		file.Write( "openvirus/client/seen_help_menu.txt", "Delete me if you want the help menu to appear automatically again." )
		GAMEMODE:ShowHelp()
	
	end

end


-- Called after entities are created
function GM:InitPostEntity()

	-- InitializeLang
	hook.Call( "InitializeLang", GAMEMODE )

	-- InitializeKillicons
	hook.Call( "InitializeKillicons", GAMEMODE )

    -- InitializeSounds
    hook.Call( "InitializeSounds", GAMEMODE )

end


-- Initialize the language stuff
function GM:InitializeLang()

	-- Worldspawn
	language.Add( "worldspawn", "World" )

	-- Weapon names
	language.Add( "weapon_ov_adrenaline", "Adrenaline Shot" )
	language.Add( "weapon_ov_dualpistol", "Dual Pistols" )
	language.Add( "weapon_ov_flak", "Flak .357" )
	language.Add( "weapon_ov_laserpistol", "Laser Gun" )
	language.Add( "weapon_ov_laserrifle", "Laser Rifle Mk. II" )
	language.Add( "weapon_ov_m3", "M3 Shotgun" )
	language.Add( "weapon_ov_mp5", "MP5 Navy" )
	language.Add( "weapon_ov_p90", "P90" )
	language.Add( "weapon_ov_pistol", "Pistol" )
	language.Add( "weapon_ov_silencedpistol", "Silenced Pistol" )
	language.Add( "weapon_ov_slam", "Proximity SLAM" )
	language.Add( "weapon_ov_sniper", "Sniper Rifle" )
	language.Add( "weapon_ov_xm1014", "XM1014 Shotgun" )

end


-- Initialize the killicons
function GM:InitializeKillicons()

	surface.CreateFont( "CSTRIKETypeDeath", { 
		font = "csd",
		size = 64,
		additive = true
    } )

	killicon.AddFont( "weapon_ov_dualpistol", "CSTRIKETypeDeath", "s", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_flak", "HL2MPTypeDeath", ".", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_laserpistol", "HL2MPTypeDeath", "-", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_laserrifle", "HL2MPTypeDeath", "2", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_m3", "CSTRIKETypeDeath", "k", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_mp5", "CSTRIKETypeDeath", "x", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_p90", "CSTRIKETypeDeath", "m", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_pistol", "CSTRIKETypeDeath", "y", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_silencedpistol", "CSTRIKETypeDeath", "a", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "ent_ov_slam", "HL2MPTypeDeath", "*", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_sniper", "CSTRIKETypeDeath", "n", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_ov_xm1014", "CSTRIKETypeDeath", "B", Color( 255, 80, 0, 255 ) )

end


-- Initialize the sounds and music
function GM:InitializeSounds()

    -- Waiting For Players music
	local OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/wfp/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_WaitingForPlayers, CreateSound( game.GetWorld(), "openvirus/music/wfp/"..v ) )
		OV_Sounds_WaitingForPlayers[ k ]:SetSoundLevel( 0 )
		OV_Sounds_WaitingForPlayers[ k ]:Stop()
	
	end

	-- PreRound music
	OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/pround/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_PreRound, CreateSound( game.GetWorld(), "openvirus/music/pround/"..v ) )
		OV_Sounds_PreRound[ k ]:SetSoundLevel( 0 )
		OV_Sounds_PreRound[ k ]:Stop()
	
	end

	-- Round music
	OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/inround/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_InRound, CreateSound( game.GetWorld(), "openvirus/music/inround/"..v ) )
		OV_Sounds_InRound[ k ]:SetSoundLevel( 0 )
		OV_Sounds_InRound[ k ]:Stop()
	
	end

	-- Last Survivor music
	OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/laststanding/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_LastSurvivor, CreateSound( game.GetWorld(), "openvirus/music/laststanding/"..v ) )
		OV_Sounds_LastSurvivor[ k ]:SetSoundLevel( 0 )
		OV_Sounds_LastSurvivor[ k ]:Stop()
	
	end

	-- Infected Win music
	OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/infected_win/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_InfectedWin, CreateSound( game.GetWorld(), "openvirus/music/infected_win/"..v ) )
		OV_Sounds_InfectedWin[ k ]:SetSoundLevel( 0 )
		OV_Sounds_InfectedWin[ k ]:Stop()
	
	end

	-- Survivors Win music
	OV_Sounds_FileList, OV_Sounds_FolderList = file.Find( "sound/openvirus/music/survivors_win/*.mp3", "GAME" )
	for k, v in pairs( OV_Sounds_FileList ) do
	
		table.insert( OV_Sounds_SurvivorsWin, CreateSound( game.GetWorld(), "openvirus/music/survivors_win/"..v ) )
		OV_Sounds_SurvivorsWin[ k ]:SetSoundLevel( 0 )
		OV_Sounds_SurvivorsWin[ k ]:Stop()
	
	end

	-- Call after we initialize the sounds
	hook.Call( "PostInitSounds", GAMEMODE )

    -- Send to the server we have initialized music
    net.Start( "OV_ClientInitializedMusic" )
    net.SendToServer()

end


-- Initialize the validation of CStrike
function GM:InitializeValidation()

	-- Validate CStrike
	net.Start( "OV_CStrikeValidation" )
		net.WriteBool( IsMounted( "cstrike" ) )
	net.SendToServer()

end


-- Called every frame
function GM:Think()

    -- Check for players around us to infect
    if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_INFECTED ) && LocalPlayer():GetInfectionStatus() ) then
    
        for _, ent in pairs( ents.FindInSphere( LocalPlayer():LocalToWorld( LocalPlayer():OBBCenter() ), 8 ) ) do
        
            if ( ent:IsValid() && ent:IsPlayer() && ( ent:Health() > 0 ) && ( ent:Team() == TEAM_SURVIVOR ) ) then
            
                net.Start( "OV_ClientsideInfect" )
                    net.WriteEntity( ent )
                net.SendToServer()
            
            end
        
        end
    
    end

    -- Update infected flame frames
    if ( OV_Material_InfectedFlameFrameUpdate < CurTime() ) then
    
        OV_Material_InfectedFlameFrameUpdate = CurTime() + 0.1
        if ( OV_Material_InfectedFlameFrameInt >= #OV_Material_InfectedFlameFrames ) then
        
            OV_Material_InfectedFlameFrameInt = 1
            OV_Material_InfectedFlame = OV_Material_InfectedFlameFrames[ 1 ]
        
        else
        
            OV_Material_InfectedFlameFrameInt = OV_Material_InfectedFlameFrameInt + 1
            OV_Material_InfectedFlame = OV_Material_InfectedFlameFrames[ OV_Material_InfectedFlameFrameInt ]
        
        end
    
    end

	-- Dynamic light
	if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_INFECTED ) && LocalPlayer():GetInfectionStatus() ) then
	
		local infected_light = DynamicLight( LocalPlayer():EntIndex() )
		if ( infected_light ) then
		
			infected_light.brightness = 0.75
			infected_light.decay = 10000
			infected_light.dietime = CurTime() + 2
			infected_light.pos = LocalPlayer():EyePos() - Vector( 0, 0, 16 )
			infected_light.size = 128
			infected_light.r = LocalPlayer():GetColor().r
			infected_light.g = LocalPlayer():GetColor().g
			infected_light.b = LocalPlayer():GetColor().b
		
		end
	
	end

	-- Geiger Counter
	if ( ov_cl_survivor_geigercounter:GetBool() && OV_Game_InRound ) then
	
		if ( LocalPlayer():IsValid() && LocalPlayer():Alive() ) then
		
			for _, ent in pairs( ents.FindInSphere( LocalPlayer():GetPos(), 1024 ) ) do
			
				if ( ent:IsValid() && ( ent:IsPlayer() && ent:Alive() && ( ent:Team() != LocalPlayer():Team() ) ) && ( !ent.OV_GeigerCounterCooldown || ( ent.OV_GeigerCounterCooldown < CurTime() ) ) ) then
				
					ent.OV_GeigerCounterCooldown = CurTime() + math.Remap( ent:GetPos():Distance( LocalPlayer():GetPos() ), 0, 1024, 0, 4 ) / 10
				
					if ( ent:GetPos():Distance( LocalPlayer():GetPos() ) <= 256 ) then
					
						surface.PlaySound( "player/geiger3.wav" )
					
					else
					
						surface.PlaySound( "player/geiger"..math.random( 1, 2 )..".wav" )
					
					end
				
				end
			
			end
		
		end
	
	end

end


-- Update Round status
function OV_UpdateRoundStatus( len )

    OV_Game_WaitingForPlayers = net.ReadBool()
    OV_Game_PreRound = net.ReadBool()
    OV_Game_InRound = net.ReadBool()
    OV_Game_EndRound = net.ReadBool()
	OV_Game_Round = net.ReadInt( 8 )
	OV_Game_MaxRounds = net.ReadInt( 8 )

end
net.Receive( "OV_UpdateRoundStatus", OV_UpdateRoundStatus )


-- Get the game timer count
function OV_SendTimerCount( len )

    if ( timer.Exists( "OV_RoundTimer" ) ) then timer.Remove( "OV_RoundTimer" ) end
    if ( timer.Exists( "OV_CountdownTimer_15" ) ) then timer.Remove( "OV_CountdownTimer_15" ) end
    if ( timer.Exists( "OV_CountdownTimer" ) ) then timer.Remove( "OV_CountdownTimer" ) end

    -- Create a fake timer as an indicator
    timer.Create( "OV_RoundTimer", net.ReadInt( 16 ), 1, function() end )

    -- If this is the main round we are gonna do count downs
    if ( OV_Game_InRound && timer.Exists( "OV_RoundTimer" ) ) then
    
        local OV_CountdownTimer_Text = {}
		local OV_CountdownTimer_Text_Number = 5
    
        timer.Create( "OV_CountdownTimer_15", timer.TimeLeft( "OV_RoundTimer" ) - 15.5, 1, function()
        
            if ( timer.Exists( "OV_RoundTimer" ) ) then
            
                OV_CountdownTimer_Text = {}
                OV_CountdownTimer_Text.text = "15 SECONDS LEFT"
                OV_CountdownTimer_Text.color = Color( 255, 0, 0 )
                OV_CountdownTimer_Text.time = CurTime() + 4
                OV_CountdownTimer_Text.timeSet = 4
            
                table.insert( OV_CountdownText, OV_CountdownTimer_Text )
                surface.PlaySound( "buttons/bell1.wav" )
            
            end
        
        end )
    
        OV_CountdownTimer_Text = {}
    
        timer.Create( "OV_CountdownTimer", timer.TimeLeft( "OV_RoundTimer" ) - 6.75, 1, function()
		
            timer.Remove( "OV_CountdownTimer" )
            timer.Create( "OV_CountdownTimer", 1, 5, function()
            
                if ( timer.Exists( "OV_RoundTimer" ) ) then
                
                    OV_CountdownTimer_Text = {}
                    OV_CountdownTimer_Text.text = tostring( OV_CountdownTimer_Text_Number )
                    OV_CountdownTimer_Text.color = Color( 255, 255, 255 )
                    OV_CountdownTimer_Text.time = CurTime() + 2.75
					OV_CountdownTimer_Text.timeSet = 2.75
                
                    table.insert( OV_CountdownText, OV_CountdownTimer_Text )
                    surface.PlaySound( "buttons/bell1.wav" )
				
					OV_CountdownTimer_Text_Number = OV_CountdownTimer_Text_Number - 1
				
                end
            
            end )
        
        end )
    
    end

end
net.Receive( "OV_SendTimerCount", OV_SendTimerCount )


-- Get some information text
function OV_SendInfoText( len )

    local SentInfoText = {}
    SentInfoText.text = net.ReadString()
    SentInfoText.color = net.ReadColor()
    SentInfoText.time = CurTime() + net.ReadInt( 4 ) + 2
	SentInfoText.timeSet = SentInfoText.time - CurTime()

    table.insert( OV_InformationText, SentInfoText )

end
net.Receive( "OV_SendInfoText", OV_SendInfoText )


-- Get damage values and put them on the screen
function OV_SendDamageValue( len )

    local SentDamageValue = {}
    SentDamageValue.dmg = net.ReadInt( 16 )
    SentDamageValue.pos = net.ReadVector()
    SentDamageValue.time = CurTime() + 3

    table.insert( OV_DamageValues, SentDamageValue )

end
net.Receive( "OV_SendDamageValue", OV_SendDamageValue )


-- Do spawn effect stuff
function OV_DoSpawnEffect( len )

    local setup_spawneffect = {}
    setup_spawneffect.pos = net.ReadVector()
    setup_spawneffect.color = net.ReadColor()
    setup_spawneffect.time = CurTime() + 1

    table.insert( OV_Material_SpawnEffectTable, setup_spawneffect )

end
net.Receive( "OV_DoSpawnEffect", OV_DoSpawnEffect )


-- Play or stop music
function OV_SetMusic( len )

    local setmusic_state = net.ReadInt( 4 )

    -- 0 is stop all music
    -- 1 is waiting for players music
    -- 2 is preround music
    -- 3 is inround music
    -- 4 is last survivor music
	-- 5 is infected win music
	-- 6 is survivors win music

	if ( !ov_cl_round_music:GetBool() ) then return end

    if ( setmusic_state <= 0 ) then
    
        for k, v in pairs( OV_Sounds_WaitingForPlayers ) do
        
            v:Stop()
        
        end
    
        for k, v in pairs( OV_Sounds_PreRound ) do
        
            v:Stop()
        
        end
    
        for k, v in pairs( OV_Sounds_InRound ) do
        
            v:Stop()
        
        end
    
        for k, v in pairs( OV_Sounds_LastSurvivor ) do
        
            v:Stop()
        
        end
    
        for k, v in pairs( OV_Sounds_InfectedWin ) do
        
            v:Stop()
        
        end
    
        for k, v in pairs( OV_Sounds_SurvivorsWin ) do
        
            v:Stop()
        
        end
    
    elseif ( setmusic_state == 1 ) then
    
        if ( #OV_Sounds_WaitingForPlayers > 0 ) then OV_Sounds_WaitingForPlayers[ math.random( 1, #OV_Sounds_WaitingForPlayers ) ]:Play() end
    
    elseif ( setmusic_state == 2 ) then
    
        if ( #OV_Sounds_PreRound > 0 ) then OV_Sounds_PreRound[ math.random( 1, #OV_Sounds_PreRound ) ]:Play() end
    
    elseif ( setmusic_state == 3 ) then
    
        if ( #OV_Sounds_InRound > 0 ) then OV_Sounds_InRound[ math.random( 1, #OV_Sounds_InRound ) ]:Play() end
    
    elseif ( setmusic_state == 4 ) then
    
        if ( #OV_Sounds_LastSurvivor > 0 ) then OV_Sounds_LastSurvivor[ math.random( 1, #OV_Sounds_LastSurvivor ) ]:Play() end
    
    elseif ( setmusic_state == 5 ) then
    
        if ( #OV_Sounds_InfectedWin > 0 ) then OV_Sounds_InfectedWin[ math.random( 1, #OV_Sounds_InfectedWin ) ]:Play() end
    
    elseif ( setmusic_state >= 6 ) then
    
        if ( #OV_Sounds_SurvivorsWin > 0 ) then OV_Sounds_SurvivorsWin[ math.random( 1, #OV_Sounds_SurvivorsWin ) ]:Play() end
    
    end

end
net.Receive( "OV_SetMusic", OV_SetMusic )


-- Called when a HUD element wants to be drawn
function OV_HUDShouldDraw( hud )

    -- Block these HUDs
    local block_huds = { CHudHealth = true, CHudBattery = true, CHudAmmo = true, CHudSecondaryAmmo = true }

    if ( block_huds[ hud ] ) then
    
        return false
    
    end

    -- Hide the crosshair for thirdperson
    if ( LocalPlayer():IsValid() && LocalPlayer():ShouldDrawLocalPlayer() && ( hud == "CHudCrosshair" ) ) then
    
        return false
    
    end

    -- Keep this in case people prefer the HL2 selection method
    if ( hud == "CHudWeaponSelection" ) then
    
        return ov_cl_hl2_wpn_selection:GetBool()
    
    end

end
hook.Add( "HUDShouldDraw", "OV_HUDShouldDraw", OV_HUDShouldDraw )


-- HUDPaint
function GM:HUDPaint()

    -- ///
    -- The HUD stuff is not final and will possibly be changed in the future
    -- ///

    -- Resolution Scale
    local hud_scale = 1

    if ( ( ScrW() > 800 ) && ( ScrH() > 600 ) ) then
    
        hud_scale = 1.5
    
        if ( ( ( ScrW() > 1920 ) && ( ScrH() > 1080 ) ) || ov_cl_hud_force_hiscale:GetBool() ) then
        
            hud_scale = 1.75
        
        end
	
		if ( ov_cl_hud_force_hiscale:GetBool() && ( ov_cl_hud_force_hiscale:GetFloat() > 1.75 ) ) then
		
			hud_scale = ov_cl_hud_force_hiscale:GetFloat()
		
		end
    
    end

	-- Colour depending on team
	local hud_color = Color( 0, 0, 100 )
	if ( LocalPlayer():Team() == TEAM_INFECTED ) then
	
		hud_color = Color( 0, 100, 0 )
	
	end

    -- If cl_drawhud is 0 or we are spectator
    if ( !GetConVar( "cl_drawhud" ):GetBool() || ( LocalPlayer():Team() == TEAM_SPECTATOR ) ) then return end

	-- Draw a text for WFP session
	if ( OV_Game_WaitingForPlayers ) then
	
		draw.SimpleTextOutlined( "WAITING FOR PLAYERS", "DermaLarge", ScrW() / 2, ScrH() / 1.5, Color( 255, 255, 255, math.Remap( math.sin( CurTime() * 4 ), -1, 1, 50, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, math.Remap( math.sin( CurTime() * 4 ), -1, 1, 50, 255 ) ) )
	
	end

    -- Damage values
    for k, v in pairs( OV_DamageValues ) do
    
        draw.SimpleTextOutlined( tostring( "-"..v.dmg ), "Trebuchet18", v.pos:ToScreen().x, ( v.pos + Vector( 0, 0, math.Remap( v.time - CurTime(), 0, 1, 8, 0 ) ) ):ToScreen().y, Color( 255, 255, 255, math.Remap( v.time - CurTime(), 0, 3, 0, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, math.Remap( v.time - CurTime(), 0, 3, 0, 255 ) ) )
    
        if ( v.time < CurTime() ) then
        
            table.remove( OV_DamageValues, k )
        
        end
    
    end

	-- Timer
	if ( !OV_Game_PreRound && !OV_Game_EndRound ) then
	
		surface.SetDrawColor( hud_color.r, hud_color.g, hud_color.b, 200 )
		surface.DrawRect( ScrW() / 2 - 30 * hud_scale, 15, 60 * hud_scale, 36 * hud_scale )
		draw.SimpleTextOutlined( "TIME LEFT", "DermaDefaultBold", ScrW() / 2, 15 * hud_scale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) )
	
		local hud_timercount = 0
		if ( timer.Exists( "OV_RoundTimer" ) ) then hud_timercount = math.Round( timer.TimeLeft( "OV_RoundTimer" ) ) end
	
		draw.SimpleTextOutlined( tostring( hud_timercount ), "CloseCaption_Bold", ScrW() / 2, 26 * hud_scale, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 255 ) )
	
	end

	-- Radar
	if ( !OV_Game_PreRound && !OV_Game_EndRound ) then
	
		surface.SetDrawColor( hud_color.r, hud_color.g, hud_color.b, 200 )
		surface.SetMaterial( OV_Material_Radar )
		surface.DrawTexturedRect( 15, 15, 128 * math.Clamp( math.Round( hud_scale - 0.01 ), 1, 2 ), 128 * math.Clamp( math.Round( hud_scale - 0.01 ), 1, 2 ) )
	
		for _, ply in pairs( player.GetAll() ) do
		
			if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_SURVIVOR || ply:Team() == TEAM_INFECTED ) && ( ply:GetPos():Distance( LocalPlayer():GetPos() ) < 1024 ) && ( ply != LocalPlayer() ) ) then
			
				-- World to Radar
				local x_diff = ply:GetPos().x - LocalPlayer():GetPos().x
				local y_diff = ply:GetPos().y - LocalPlayer():GetPos().y
			
				if ( x_diff == 0 ) then x_diff = 0.00001 end
				if ( y_diff == 0 ) then y_diff = 0.00001 end
			
				local iRadarRadius = 128 * math.Clamp( math.Round( hud_scale - 0.01 ), 1, 2 )
			
				local fScale = ( iRadarRadius / 2.56 ) / 1024
			
				local flOffset = math.atan( y_diff / x_diff )
				flOffset = flOffset * 180
				flOffset = flOffset / math.pi
			
				if ( ( x_diff < 0 ) && ( y_diff >= 0 ) ) then
				
					flOffset = 180 + flOffset
				
				elseif ( ( x_diff < 0 ) && ( y_diff < 0 ) ) then
				
					flOffset = 180 + flOffset
				
				elseif ( ( x_diff >= 0 ) && ( y_diff < 0 ) ) then
				
					flOffset = 360 + flOffset
				
				end
			
				y_diff = -1 * ( math.sqrt( ( ( x_diff ) * ( x_diff ) + ( y_diff ) * ( y_diff ) ) ) )
				x_diff = 0
			
				flOffset = LocalPlayer():GetAngles().y - flOffset
			
				flOffset = flOffset * math.pi
				flOffset = flOffset / 180
			
				local xnew_diff = x_diff * math.cos( flOffset ) - y_diff * math.sin( flOffset )
				local ynew_diff = x_diff * math.sin( flOffset ) + y_diff * math.cos( flOffset )
			
				xnew_diff = ( xnew_diff * fScale ) + 13
				ynew_diff = ( ynew_diff * fScale ) + 13
			
				-- Draw the radar here
				local dot_color = Color( 255, 255, 255 )
				if ( LocalPlayer():Team() != ply:Team() ) then
				
					dot_color = Color( 255, 0, 0 )
				
				end
			
				surface.SetDrawColor( dot_color.r, dot_color.g, dot_color.b, math.Remap( LocalPlayer():GetPos():Distance( ply:GetPos() ), 1000, 1024, 200, 0 ) )
				surface.SetMaterial( OV_Material_RadarPoint )
				surface.DrawTexturedRect( ( iRadarRadius / 2 ) + xnew_diff, ( iRadarRadius / 2 ) + ynew_diff , 4 * math.Clamp( math.Round( hud_scale - 0.01 ), 1, 2 ), 4 * math.Clamp( math.Round( hud_scale - 0.01 ), 1, 2 ) )
			
			end
		
		end
	
	end

    -- GM Weapon Selection
    if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) && ( OV_WeaponSelectionNameTime > CurTime() ) ) then
    
        draw.SimpleTextOutlined( "#"..OV_WeaponSelectionName, "TargetID", ScrW() / 2, ScrH() / 2 - 60, Color( 255, 255, 255, math.Remap( OV_WeaponSelectionNameTime - CurTime(), 0, 0.5, 0, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, math.Remap( OV_WeaponSelectionNameTime - CurTime(), 0, 0.5, 0, 255 ) ) )
    
    end

    -- Countdown Text
    for k, v in pairs( OV_CountdownText ) do
    
        draw.SimpleTextOutlined( v.text, "DermaLarge", ( ScrW() / 2 ) + math.Clamp( math.Remap( v.time - CurTime(), v.timeSet - 1, v.timeSet, 0, ScrW() / 1.5 ), 0, ScrW() ) - math.Clamp( math.Remap( v.time - CurTime(), 1, 0, 0, ScrW() / 1.5 ), 0, ScrW() ), ScrH() / 2 + 60, Color( v.color.r, v.color.g, v.color.b, v.color.a - math.Remap( v.time - CurTime(), 1, 0, 0, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, v.color.a - math.Remap( v.time - CurTime(), 1, 0, 0, 255 ) ) )
    
        if ( v.time < CurTime() ) then
        
            table.remove( OV_CountdownText, k )
        
        end
    
    end

    -- Information Text
    for k, v in pairs( OV_InformationText ) do
    
        draw.SimpleTextOutlined( v.text, "CloseCaption_Normal", ( ScrW() / 2 ) + math.Clamp( math.Remap( v.time - CurTime(), v.timeSet - 1, v.timeSet, 0, ScrW() / 1.5 ), 0, ScrW() ) - math.Clamp( math.Remap( v.time - CurTime(), 1, 0, 0, ScrW() / 1.5 ), 0, ScrW() ), ScrH() / 2 + 60 + ( 40 * k ), Color( v.color.r, v.color.g, v.color.b, v.color.a - math.Remap( v.time - CurTime(), 1, 0, 0, 255 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, v.color.a - math.Remap( v.time - CurTime(), 1, 0, 0, 255 ) ) )
    
        if ( v.time < CurTime() ) then
        
            table.remove( OV_InformationText, k )
        
        end
    
    end

    -- Ammo Counter
    if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon():IsValid() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) ) then
    
        local ammocounter_primaryclip = LocalPlayer():GetActiveWeapon():Clip1().." /"
        if ( LocalPlayer():GetActiveWeapon():Clip1() < 0 ) then ammocounter_primaryclip = "" end
        local ammocounter_primarycount = ""
        if ( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() > 0 ) then ammocounter_primarycount = " "..LocalPlayer():GetAmmoCount( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() ).." " end
        local ammocounter_secondarycount = ""
        if ( LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() > 0 ) then ammocounter_secondarycount = "| "..LocalPlayer():GetAmmoCount( LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() ) end
    
        draw.SimpleTextOutlined( ammocounter_primaryclip..""..ammocounter_primarycount..""..ammocounter_secondarycount, "DermaLarge", ScrW() - 15, ScrH() - 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 255 ) )
    
    end

    -- Paint death notices
    hook.Run( "DrawDeathNotice", 0.85, 0.04 )

	-- Use this splash text when the player does not own CSS
	if ( !IsMounted( "cstrike" ) ) then
	
		draw.SimpleText( "YOU ARE PLAYING OPEN VIRUS.", "BudgetLabel", 4, ScrH() - 45, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "WE ARE NOT AFFILIATED WITH PIXELTAIL!", "BudgetLabel", 4, ScrH() - 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "BUY TOWER UNITE TO PLAY THE OFFICIAL VIRUS GAME", "BudgetLabel", 4, ScrH(), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	
	end

end


-- HUDPaint Background
function GM:HUDPaintBackground()

	-- Draw a 3D crosshair in Survivor thirdperson
	if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) && LocalPlayer():ShouldDrawLocalPlayer() && ( LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon():IsValid() ) ) then
	
		surface.SetDrawColor( 255, 220, 0, 255 )
		surface.DrawRect( LocalPlayer():GetEyeTrace().HitPos:ToScreen().x, LocalPlayer():GetEyeTrace().HitPos:ToScreen().y + 8, 1, 1 )
		surface.DrawRect( LocalPlayer():GetEyeTrace().HitPos:ToScreen().x + 10, LocalPlayer():GetEyeTrace().HitPos:ToScreen().y, 1, 1 )
		surface.DrawRect( LocalPlayer():GetEyeTrace().HitPos:ToScreen().x, LocalPlayer():GetEyeTrace().HitPos:ToScreen().y, 1, 1 )
		surface.DrawRect( LocalPlayer():GetEyeTrace().HitPos:ToScreen().x - 10, LocalPlayer():GetEyeTrace().HitPos:ToScreen().y, 1, 1 )
		surface.DrawRect( LocalPlayer():GetEyeTrace().HitPos:ToScreen().x, LocalPlayer():GetEyeTrace().HitPos:ToScreen().y - 8, 1, 1 )
	
	end

end


-- Called after when rendering opaque renderables
function OV_PostDrawTranslucentRenderables( depth, skybox )

    -- Show spawn effect sprites
    for k, v in pairs( OV_Material_SpawnEffectTable ) do
    
        render.SetMaterial( OV_Material_SpawnEffectSprite )
        render.DrawSprite( v.pos, 128, 128, v.color )
    
        if ( v.time < CurTime() ) then
        
            table.remove( OV_Material_SpawnEffectTable, k )
        
        end
    
    end

    -- Show the infected flame
    for _, ply in pairs( team.GetPlayers( TEAM_INFECTED ) ) do
    
        -- Render the sprite
        if ( ply:IsValid() && ply:Alive() && ply:GetInfectionStatus() ) then
        
            cam.Start3D2D( ply:GetPos(), Angle( 0, LocalPlayer():EyeAngles().y - 90, 90 ), 0.5 )
            
                local flame_red, flame_green, flame_blue = 180, 255, 0
                if ( ply:GetEnragedStatus() ) then
                
                    flame_red, flame_green, flame_blue = 255, 255, 255
                
                end
            
                surface.SetDrawColor( flame_red, flame_green, flame_blue, 255 )
                surface.SetMaterial( OV_Material_InfectedFlame )
                surface.DrawTexturedRect( -50, -292, 100, 300 )
            
            cam.End3D2D()
        
        end
    
    end

    -- Begin 3D TargetID
    for _, ply in pairs( player.GetAll() ) do
    
        -- Render the 3D Text
        if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_SURVIVOR || ply:Team() == TEAM_INFECTED ) && ( ply:GetPos():Distance( LocalPlayer():GetPos() ) < 512 ) && ( ply != LocalPlayer() ) ) then
        
            cam.Start3D2D( ply:GetPos(), Angle( 0, LocalPlayer():EyeAngles().y - 90, 90 ), 0.5 )
            
                draw.SimpleText( ply:Name(), "DermaLarge", 40, -120, Color( 255, 255, 255, math.Remap( ply:GetPos():Distance( LocalPlayer():GetPos() ), 412, 512, 255, 0 ) ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            
                local hud_teamname = "WAITING"
                if ( OV_Game_InRound ) then
                
                    if ( ply:Team() == TEAM_SURVIVOR ) then
                    
                        hud_teamname = ""
                    
                    elseif ( ply:Team() == TEAM_INFECTED ) then
                    
                        hud_teamname = "INFECTED"
                    
                    end
                
                end
            
                draw.SimpleText( hud_teamname, "Trebuchet24", 40, -90, Color( 127.5, 127.5, 127.5, math.Remap( ply:GetPos():Distance( LocalPlayer():GetPos() ), 412, 512, 255, 0 ) ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
            
            cam.End3D2D()
        
        end
    
    end

    -- Show infected player health
    if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_INFECTED ) && ( LocalPlayer():GetNWInt( "InfectedLastHurt", 0 ) > CurTime() ) ) then
    
        cam.Start3D2D( LocalPlayer():GetPos(), Angle( 0, LocalPlayer():EyeAngles().y - 270, 90 ), 0.5 )
        
            surface.SetDrawColor( 0, 0, 0, math.Clamp( math.Remap( LocalPlayer():GetNWInt( "InfectedLastHurt", 0 ) - CurTime(), 0, 1, 0, 127.5 ), 0, 127.5 ) )
            surface.DrawRect( 40, -120, 16, 64 )
            surface.SetDrawColor( 255, 127.5, 0, math.Clamp( math.Remap( LocalPlayer():GetNWInt( "InfectedLastHurt", 0 ) - CurTime(), 0, 1, 0, 127.5 ), 0, 127.5 ) )
            surface.DrawRect( 41, -119 + math.Remap( LocalPlayer():Health(), 0, LocalPlayer():GetMaxHealth(), 62, 0 ), 14, math.Remap( LocalPlayer():Health(), 0, LocalPlayer():GetMaxHealth(), 0, 62 ) )
        
        cam.End3D2D()
    
    end

end
hook.Add( "PostDrawTranslucentRenderables", "OV_PostDrawTranslucentRenderables", OV_PostDrawTranslucentRenderables )


-- Called when the player view is calculated
function OV_CalcView( ply, pos, ang, fov, zn, zf )

    -- Infected thirdperson
    if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( ( LocalPlayer():Team() == TEAM_INFECTED ) || OV_Game_WaitingForPlayers ) ) then
    
        local tracepos = {}
        tracepos.start = pos
        tracepos.endpos = pos - ( ply:GetAimVector() * 128 ) + Vector( 0, 0, 16 )
        tracepos.filter = player.GetAll()
        tracepos.mins = Vector( -4, -4, -4 )
        tracepos.maxs = Vector( 4, 4, 4 )
    
        local tracepos = util.TraceHull( tracepos )
    
        local view = {}
        view.origin = tracepos.HitPos
        view.angles = ang
        view.fov = fov
        view.znear = zn
        view.zfar = zf
        view.drawviewer = true
    
        return view
    
    end

	-- Survivor thirdperson
    if ( ov_cl_survivor_thirdperson:GetBool() && LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) ) then
    
        local tracepos = {}
        tracepos.start = pos
    
        if ( ov_cl_survivor_thirdperson_right:GetBool() ) then
        
            tracepos.endpos = pos - ( ( ply:GetAimVector() * 54 ) - ( ply:EyeAngles():Right() * 16 ) )
        
        else
        
		    tracepos.endpos = pos - ( ( ply:GetAimVector() * 54 ) + ( ply:EyeAngles():Right() * 16 ) )
        
        end
    
        tracepos.filter = player.GetAll()
        tracepos.mins = Vector( -8, -8, -8 )
        tracepos.maxs = Vector( 8, 8, 8 )
    
        local tracepos = util.TraceHull( tracepos )
    
        local view = {}
        view.origin = tracepos.HitPos
        view.angles = ang
        view.fov = fov
        view.znear = zn
        view.zfar = zf
        view.drawviewer = true
    
        return view
    
    end

	-- Survivor firstperson
	if ( ov_cl_camera_bob:GetBool() && LocalPlayer():IsValid() && LocalPlayer():Alive() && LocalPlayer():IsOnGround() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) ) then
	
		local view = {}
		view.origin = pos
		view.angles = Angle( ang.p + ( math.cos( CurTime() * 7.25 ) * math.Remap( LocalPlayer():GetVelocity():Length(), 0, GAMEMODE.OV_Survivor_Speed, 0, 0.25 ) ), ang.y, ang.r + ( math.Remap( LocalPlayer():EyeAngles():Right():Dot( LocalPlayer():GetVelocity() ), 0, LocalPlayer():GetMaxSpeed(), 0, 6 ) ) + ( math.cos( CurTime() * 9 ) * math.Remap( LocalPlayer():GetVelocity():Length(), 0, GAMEMODE.OV_Survivor_Speed, 0, 1 ) ) )
		view.fov = fov
		view.znear = zn
		view.zfar = zf
		view.drawviewer = false
	
		return view
	
	end

end
hook.Add( "CalcView", "OV_CalcView", OV_CalcView )


-- Called when a key is pressed
function OV_PlayerBindPress( ply, key, pressed )

    -- Switch to the next weapon on the list
    if ( !ov_cl_hl2_wpn_selection:GetBool() && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( key == "invnext" ) ) then
    
        OV_WeaponSelectionTable = {}
        for k , v in pairs( ply:GetWeapons() ) do table.insert( OV_WeaponSelectionTable, v ) end
    
        for k, v in pairs( OV_WeaponSelectionTable ) do
        
            if ( v:GetClass() == ply:GetActiveWeapon():GetClass() ) then
            
                if ( k == #OV_WeaponSelectionTable ) then k = 0 end
            
                ply:ConCommand( "invwep "..OV_WeaponSelectionTable[ k + 1 ]:GetClass() )
            
                OV_WeaponSelectionName = OV_WeaponSelectionTable[ k + 1 ]:GetClass()
                OV_WeaponSelectionNameTime = CurTime() + 2
            
                surface.PlaySound( "common/wpn_hudoff.wav" )
            
            end
        
        end
    
    end

    -- Switch to the previous weapon on the list
    if ( !ov_cl_hl2_wpn_selection:GetBool() && ply:GetActiveWeapon() && ply:GetActiveWeapon():IsValid() && ( key == "invprev" ) ) then
    
        OV_WeaponSelectionTable = {}
        for k , v in pairs( ply:GetWeapons() ) do table.insert( OV_WeaponSelectionTable, v ) end
    
        for k, v in pairs( OV_WeaponSelectionTable ) do
        
            if ( v:GetClass() == ply:GetActiveWeapon():GetClass() ) then
            
                if ( k == 1 ) then k = #OV_WeaponSelectionTable + 1 end
            
                ply:ConCommand( "invwep "..OV_WeaponSelectionTable[ k - 1 ]:GetClass() )
            
                OV_WeaponSelectionName = OV_WeaponSelectionTable[ k - 1 ]:GetClass()
                OV_WeaponSelectionNameTime = CurTime() + 2
            
                surface.PlaySound( "common/wpn_hudoff.wav" )
            
            end
        
        end
    
    end

    -- Slot actions
    if ( !ov_cl_hl2_wpn_selection:GetBool() && string.find( key, "slot" ) ) then
    
        OV_WeaponSelectionTable = {}
        for k , v in pairs( ply:GetWeapons() ) do table.insert( OV_WeaponSelectionTable, v ) end
    
        local weapon_num = tonumber( string.sub( key, 5 ) )
        for k, v in pairs( OV_WeaponSelectionTable ) do
        
            if ( k == weapon_num ) then
            
                ply:ConCommand( "invwep "..v:GetClass() )
            
                OV_WeaponSelectionName = v:GetClass()
                OV_WeaponSelectionNameTime = CurTime() + 2
            
                surface.PlaySound( "common/wpn_hudoff.wav" )
            
            end
        
        end
    
    end

	-- Adrenaline shortcut
	if ( ply:HasWeapon( "weapon_ov_adrenaline" ) && ( key == "+menu_context" ) ) then
    
        ply:ConCommand( "invwep "..ply:GetWeapon( "weapon_ov_adrenaline" ):GetClass() )
	
		OV_WeaponSelectionName = ply:GetWeapon( "weapon_ov_adrenaline" ):GetClass()
		OV_WeaponSelectionNameTime = CurTime() + 2
    
        surface.PlaySound( "common/wpn_hudoff.wav" )
    
	end

    -- Switch to the last weapon used
    if ( ov_cl_hl2_wpn_selection:GetBool() && key == "+menu" ) then
    
        ply:ConCommand( "lastinv" )
    
    end

end
hook.Add( "PlayerBindPress", "OV_PlayerBindPress", OV_PlayerBindPress )


-- Render Screenspace Effects
function OV_RenderScreenspaceEffects()

	if ( ov_cl_screenspace_effects:GetBool() ) then
	
		-- Last Survivor
		if ( OV_Game_InRound && LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) && ( team.NumPlayers( TEAM_SURVIVOR ) < 2 ) ) then
		
			DrawBloom( 0.75, 2, 9, 9, 1, 1, 1, 1, 1 )
		
		end

		-- Adrenaline effect
		if ( LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) && LocalPlayer():GetAdrenalineStatus() ) then
		
			DrawMotionBlur( 0.25, 0.75, 0.01 )
			DrawSharpen( 1.1, 1.1 )
			DrawToyTown( 1.1, ScrH() / 2 )
		
		end
	
		-- Preparing for the next round
		if ( OV_Game_EndRound && timer.Exists( "OV_RoundTimer" ) ) then
		
			DrawColorModify( { [ "$pp_colour_contrast" ] = 1, [ "$pp_colour_colour" ] = math.Clamp( math.Remap( timer.TimeLeft( "OV_RoundTimer" ), 0, 15, 0, 1 ), 0, 1 ) } )
		
		end
	
	end

end
hook.Add( "RenderScreenspaceEffects", "OV_RenderScreenspaceEffects", OV_RenderScreenspaceEffects )


-- Emitted sounds
function OV_EntityEmitSound( data )

    -- Adrenaline effect
    if ( ( data.Entity != game.GetWorld() ) && ov_cl_sound_dsp_effects:GetBool() && LocalPlayer():IsValid() && LocalPlayer():Alive() && ( LocalPlayer():Team() == TEAM_SURVIVOR ) && LocalPlayer():GetAdrenalineStatus() ) then
    
        data.DSP = 58
        return true
    
    end

end
hook.Add( "EntityEmitSound", "OV_EntityEmitSound", OV_EntityEmitSound )


-- Basic Help VGUI
function GM:ShowHelp()

	local helpframe = vgui.Create( "DFrame" )
	helpframe:SetSize( 640, 480 )
	helpframe:SetDraggable( false )
	helpframe:SetBackgroundBlur( true )
	helpframe:SetTitle( "Help" )

	local helppanel = vgui.Create( "DPanel", helpframe )
	helppanel:Dock( FILL )

	local helplabel = vgui.Create( "DLabel", helppanel )
	helplabel:SetPos( 2, 2 )
	helplabel:SetColor( Color( 0, 0, 0, 255 ) )
	helplabel:SetText( "How to play open Virus:\n\nThe gamemode is essentially zombie survival but with fast-paced rounds.\nSurvivors must survive the entire round (typically 90 seconds) in order to win.\nInfected must spread the virus to all survivors within the given time in order to win.\n\nPlayers CANNOT use basic movement keys such as crouching, jumping or zooming.\nSurvivors can use C to quick-switch to adrenaline.\nSurvivors should work as a team.\nInfected must be aware of SLAMs.\nInfected must run into players to infect them." )
	helplabel:SizeToContents()

	local helplabel_size_x, helplabel_size_y = helplabel:GetSize()
	helpframe:SetSize( helplabel_size_x + 4, helplabel_size_y + 40 )
	helpframe:Center()
	helpframe:MakePopup()

end
