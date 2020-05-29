
HotPursuitMaps = {} --Initializes the map table, don't touch

--[[ HotPursuitMaps["rp_rockford_v2b"] = { --Example of a full feature map
	[1] = { --Layout of the track
		Name = "Standard",
		Description = "Standard track layout around Rockford.",
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
		Name = "Reversed",
		Description = "Same as standard but the places of the starting line and finish line are swapped.",
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
} ]]

--[[ HotPursuitMaps["fightspace3b"] = { --Example of a free roam only map
	[1] = {
		Name = "Standard Free Roam",
		Description = "Standard track, free roam only.",
		FreeRoamOnly = true, --Whether the map only supports the free roam track type or not (this will usually be applied to open maps where a reasonable amount of barriers wouldn't be enough to prevent track cutting)
		StartPos = {
			Pos = vector_origin,
			Ang = angle_zero
		}
	}
} ]]

--Functions to read/write map info in the file system, don't touch
if SERVER then
	local color_blue = Color( 0, 0, 255 )
	function ReadCurrentMap()
		if !HotPursuitMaps then
			MsgC( color_blue, "Error: It seems like the main map table doesn't exist. The gamemode will not work without it. Did you mess with something you weren't supposed to?" )
			return
		end
		local map = game.GetMap()
		if !HotPursuitMaps[map] then
			MsgC( color_blue, "Info for this map not found. Attempting to load from file..." )
			if file.Exists( "hotpursuit/maps/"..map..".json", "DATA" ) then
				local info = file.Read( "hotpursuit/maps/"..map..'.json', "DATA" )
				local convert = util.JSONToTable( info )
				HotPursuitMaps[map] = convert
				MsgC( color_blue, "Successfully loaded map info from file." )
				return
			end
			MsgC( color_blue, "Error: Could not find info for this map. This map may be unsupported." )
			return
		end
		MsgC( color_blue, "Info for this map already exists in memory. No action taken." )
	end
	hook.Add( "InitPostEntity", "HP_LoadMapInfo", ReadCurrentMap )

	function WriteMapsToFile()
		for k,v in pairs( HotPursuitMaps ) do
			if !file.Exists( "hotpursuit/maps", "DATA" ) then file.CreateDir( "hotpursuit/maps" ) end
			file.Write( "hotpursuit/maps/"..k..".json", util.TableToJSON( v, true ) )
			MsgC( color_blue, "Map info successfully written to file. You can safely delete the Lua tables in hp_maps.lua." )
		end
	end
	concommand.Add( "hp_writemaps", WriteMapsToFile )
end
