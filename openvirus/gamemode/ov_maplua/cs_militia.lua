-- Fix up cs_militia for Virus gameplay


function OVMap_PostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "func_door_rotating" ) ) do
	
		ent:Fire( "Open" )
        ent:Fire( "Kill", "", "1" )
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
