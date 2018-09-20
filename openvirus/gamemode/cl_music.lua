-- Initialize the music system


-- Console Variables
local enableRoundMusic = CreateClientConVar( "ov_cl_round_music", "1", true, false )


-- Adds the music path to the game
local waitingForPlayersMusic = {}
local preRoundMusic = {}
local inRoundMusic = {}
local lastSurvivorMusic = {}
local infectedWinMusic = {}
local survivorsWinMusic = {}
function GM:AddMusicPath( path, musicType, fileType )

	if ( !isstring( path ) ) then return; end
	if ( !isnumber( musicType ) ) then return; end
	if ( !isstring( fileType ) ) then return; end

	local searchPath = path;
	if ( string.Right( searchPath, 1 ) != "/" ) then
	
		searchPath = searchPath.."/"
	
	end

	local searchPathFind = searchPath
	if ( fileType == "wav" ) then
	
		searchPathFind = "sound/"..searchPath.."*.wav"
	
	elseif ( fileType == "mp3" ) then
	
		searchPathFind = "sound/"..searchPath.."*.mp3"
	
	else
	
		print( "No file type specified!" )
		return
	
	end

	local fileList, folderList = file.Find( searchPathFind, "GAME" )
	for k, v in ipairs( fileList ) do
	
		if ( musicType == ROUNDMUSIC_WFP ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #waitingForPlayersMusic + 1
			waitingForPlayersMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			waitingForPlayersMusic[ index ]:SetSoundLevel( 0 )
			waitingForPlayersMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_PREROUND ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #preRoundMusic + 1
			preRoundMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			preRoundMusic[ index ]:SetSoundLevel( 0 )
			preRoundMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INROUND ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #inRoundMusic + 1
			inRoundMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			inRoundMusic[ index ]:SetSoundLevel( 0 )
			inRoundMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_LASTSURVIVOR ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #lastSurvivorMusic + 1
			lastSurvivorMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			lastSurvivorMusic[ index ]:SetSoundLevel( 0 )
			lastSurvivorMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INFECTEDWIN ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #infectedWinMusic + 1
			infectedWinMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			infectedWinMusic[ index ]:SetSoundLevel( 0 )
			infectedWinMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_SURVIVORSWIN ) then
		
			util.PrecacheSound( searchPath..v )
		
			local index = #survivorsWinMusic + 1
			survivorsWinMusic[ index ] = CreateSound( game.GetWorld(), searchPath..v )
			survivorsWinMusic[ index ]:SetSoundLevel( 0 )
			survivorsWinMusic[ index ]:Stop()
		
		else
		
			print( "No valid music type specified!" )
		
		end
	
	end

end


-- Adds a specific music file to the game
function GM:AddMusicFile( searchFile, musicType )

	if ( !isstring( searchFile ) ) then return; end
	if ( !isnumber( musicType ) ) then return; end

	searchFilePath = "sound/"..searchFile

	if ( file.Exists( searchFilePath, "GAME" ) && ( ( string.Right( searchFilePath, 4 ) == ".wav" ) || ( string.Right( searchFilePath, 4 ) == ".mp3" ) ) ) then
	
		if ( musicType == ROUNDMUSIC_WFP ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #waitingForPlayersMusic + 1
			waitingForPlayersMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			waitingForPlayersMusic[ index ]:SetSoundLevel( 0 )
			waitingForPlayersMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_PREROUND ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #preRoundMusic + 1
			preRoundMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			preRoundMusic[ index ]:SetSoundLevel( 0 )
			preRoundMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INROUND ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #inRoundMusic + 1
			inRoundMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			inRoundMusic[ index ]:SetSoundLevel( 0 )
			inRoundMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_LASTSURVIVOR ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #lastSurvivorMusic + 1
			lastSurvivorMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			lastSurvivorMusic[ index ]:SetSoundLevel( 0 )
			lastSurvivorMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_INFECTEDWIN ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #infectedWinMusic + 1
			infectedWinMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			infectedWinMusic[ index ]:SetSoundLevel( 0 )
			infectedWinMusic[ index ]:Stop()
		
		elseif ( musicType == ROUNDMUSIC_SURVIVORSWIN ) then
		
			util.PrecacheSound( searchFile )
		
			local index = #survivorsWinMusic + 1
			survivorsWinMusic[ index ] = CreateSound( game.GetWorld(), searchFile )
			survivorsWinMusic[ index ]:SetSoundLevel( 0 )
			survivorsWinMusic[ index ]:Stop()
		
		else
		
			print( "No valid music type specified!" )
		
		end
	
	end

end


-- Play or stop music
function SetRoundMusic( len )

	local musicState = net.ReadInt( 4 )

	if ( !enableRoundMusic:GetBool() ) then return end

	if ( musicState <= ROUNDMUSIC_STOP ) then
	
		for k, v in pairs( waitingForPlayersMusic ) do
		
			v:Stop()
		
		end
	
		for k, v in pairs( preRoundMusic ) do
		
			v:Stop()
		
		end
	
		for k, v in pairs( inRoundMusic ) do
		
			v:Stop()
		
		end
	
		for k, v in pairs( lastSurvivorMusic ) do
		
			v:Stop()
		
		end
	
		for k, v in pairs( infectedWinMusic ) do
		
			v:Stop()
		
		end
	
		for k, v in pairs( survivorsWinMusic ) do
		
			v:Stop()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_WFP ) then
	
		if ( #waitingForPlayersMusic > 0 ) then
		
			table.Random( waitingForPlayersMusic ):Play()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_PREROUND ) then
	
		if ( #preRoundMusic > 0 ) then
		
			table.Random( preRoundMusic ):Play()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_INROUND ) then
	
		if ( #inRoundMusic > 0 ) then
		
			table.Random( inRoundMusic ):Play()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_LASTSURVIVOR ) then
	
		if ( #lastSurvivorMusic > 0 ) then
		
			table.Random( lastSurvivorMusic ):Play()
		
		end
	
	elseif ( musicState == ROUNDMUSIC_INFECTEDWIN ) then
	
		if ( #infectedWinMusic > 0 ) then
		
			table.Random( infectedWinMusic ):Play()
		
		end
	
	elseif ( musicState >= ROUNDMUSIC_SURVIVORSWIN ) then
	
		if ( #survivorsWinMusic > 0 ) then
		
			table.Random( survivorsWinMusic ):Play()
		
		end
	
	end

end
net.Receive( "SetRoundMusic", SetRoundMusic )


-- Debug purposes only
function GM:PrintMusicTable()

	print( "-= START =-" )
	print( "Waiting For Players:" )
	PrintTable( waitingForPlayersMusic )
	print( "Pre-Round:" )
	PrintTable( preRoundMusic )
	print( "Main Round:" )
	PrintTable( inRoundMusic )
	print( "Last Survivor:" )
	PrintTable( lastSurvivorMusic )
	print( "Infected Win:" )
	PrintTable( infectedWinMusic )
	print( "Survivors Win:" )
	PrintTable( survivorsWinMusic )
	print( "-= END =-" )

end
