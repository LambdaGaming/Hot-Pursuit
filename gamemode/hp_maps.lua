
HotPursuitMaps = {} --Initializes the map table, don't touch
angle_ninety = Angle( 0, 90, 0 ) --Global variable for optimization, don't touch

--[[
HotPursuitMaps["rp_rockford_v2b"] = { --Example of a full feature map
	[1] = { --Layout of the track, the '[1] =' isn't required but helps keeps things organized
		Name = "Standard",
		Description = "Standard track layout.",
		BlockSpawns = { --Positions of the barriers that prevent racers from going off-course, each barrier has 2 extra barriers spawned on either side of it
			{ vector_origin, angle_zero }, --Angle yaw must be either 0 or 90
		},
		StartPos = { --Until the angles bug is fixed, players will have a physical line that they'll start behind
			Pos = vector_origin,
			Ang = angle_zero
		},
		FinishPos = { --Position of the finish line
			Pos = vector_origin,
			Ang = angle_zero
		}
	},
	[2] = {
		Name = "Urban Sprint",
		Description = "Track stays inside the city.",
		BlockSpawns = {
			{ vector_origin, angle_zero }
		},
		StartPos = {
			Pos = vector_origin,
			Ang = angle_zero
		},
		FinishPos = {
			Pos = vector_origin,
			Ang = angle_zero
		}
	}
}
]]

--Functions to read/write map info in the file system, don't touch
if SERVER then
	local color_blue = Color( 0, 0, 255 )
	local function PrintToConsole( text, suppress )
		if suppress then return end
		MsgC( color_blue, text )
	end

	function ReadCurrentMap( suppress )
		if !HotPursuitMaps then
			PrintToConsole( "\nError: It seems like the main map table doesn't exist. The gamemode will not work without it. Did you mess with something you weren't supposed to?\n", suppress )
			return
		end
		local map = game.GetMap()
		if !HotPursuitMaps[map] then
			PrintToConsole( "\nInfo for this map not found. Attempting to load from file...\n", suppress )
			local infoextra = file.Read( "hotpursuit/maps/"..map..'.json', "DATA" )
			local info = file.Read( "gamemodes/hotpursuit/content/data/hotpursuit/maps/"..map..".json", "GAME" )
			local filefoundinmaindir = false
			local convert
			if info == nil then
				PrintToConsole( "\nMap info not found in gamemode directory. Checking main data directory.\n", suppress )
				if infoextra == nil then
					PrintToConsole( "\nError: This map is unsupported. Only free roam mode will be available.\n", suppress )
					return
				end
			else
				filefoundinmaindir = true
			end
			if filefoundinmaindir then
				convert = util.JSONToTable( info )
			else
				convert = util.JSONToTable( infoextra )
			end
			HotPursuitMaps[map] = convert
			PrintToConsole( "\nSuccessfully loaded map info from file.\n", suppress )
			return
		end
		PrintToConsole( "\nInfo for this map already exists in memory. No action taken.\n", suppress )
	end
	hook.Add( "InitPostEntity", "HP_LoadMapInfo", ReadCurrentMap )

	function WriteMapsToFile()
		for k,v in pairs( HotPursuitMaps ) do
			if !file.Exists( "hotpursuit/maps", "DATA" ) then file.CreateDir( "hotpursuit/maps" ) end
			file.Write( "hotpursuit/maps/"..k..".json", util.TableToJSON( v, true ) )
			MsgC( color_blue, "\nMap info for "..k.." successfully written to file. You can safely delete it's Lua table in hp_maps.lua.\n" )
		end
	end
	concommand.Add( "hp_writemaps", WriteMapsToFile )
end
