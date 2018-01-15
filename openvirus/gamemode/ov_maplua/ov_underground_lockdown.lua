-- Make ov_underground_lockdown default the player flashlights to true


function OVMap_PlayerSpawn( ply )

    -- Turn on the flashlight
	if ( ply:IsValid() && ply:Alive() && ( ply:Team() == TEAM_SURVIVOR ) ) then
    
        ply:Flashlight( true )
    
    end

end
hook.Add( "PlayerSpawn", "OVMap_PlayerSpawn", OVMap_PlayerSpawn )
