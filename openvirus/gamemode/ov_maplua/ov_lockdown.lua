-- Fix up some left over mistakes in ov_lockdown

if ( CLIENT ) then return end


function OVMap_PostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "item_*" ) ) do
	
		ent:Remove()
	
    end

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		if ( ent:GetModel() == "models/props_junk/metalbucket01a.mdl" ) then
		
			ent:Remove()
		
		end
	
		if ( ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then
		
			timer.Simple( 2, function() if ( ent && ent:IsValid() && ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then ent:GetPhysicsObject():EnableMotion( false ) end end )
		
		end
	
    end

end
hook.Add( "PostCleanupMap", "OVMap_PostCleanupMap", OVMap_PostCleanupMap )
