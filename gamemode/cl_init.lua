
include( "shared.lua" )

hook.Add( "SpawnMenuOpen", "HPSpawnMenu", function()
	local ply = LocalPlayer()
	return ply:IsSuperAdmin()
end )