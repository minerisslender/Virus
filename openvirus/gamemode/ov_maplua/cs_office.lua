-- Fix up cs_office for Virus gameplay

if ( CLIENT ) then return end


function OVMap_PostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "func_breakable*" ) ) do
	
		ent:Fire( "SetHealth", "" )
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
