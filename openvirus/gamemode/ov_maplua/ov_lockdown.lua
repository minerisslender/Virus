-- Fix up some left over mistakes in ov_lockdown

if ( CLIENT ) then return end


function OVMap_PostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "item_*" ) ) do
	
		ent:Remove()
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
