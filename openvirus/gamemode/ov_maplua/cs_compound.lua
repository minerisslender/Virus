-- Fix up cs_compound for Virus gameplay


function OVMap_PostCleanupMap()

	ents.FindByClass( "info_player_start" )[ 1 ]:Remove()

	for _, ent in pairs( ents.FindByClass( "func_breakable" ) ) do
	
		ent:Fire( "SetHealth", "0" )
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
