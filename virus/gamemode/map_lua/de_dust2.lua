-- Fix up de_dust2 for Virus gameplay

AddCSLuaFile()

if ( CLIENT ) then return; end


function VirusMapPostCleanupMap()

	for _, ent in pairs( ents.FindByClass( "prop_physics*" ) ) do
	
		ent:Remove()
	
    end

end
hook.Add( "PostCleanupMap", "VirusMapPostCleanupMap", VirusMapPostCleanupMap )
