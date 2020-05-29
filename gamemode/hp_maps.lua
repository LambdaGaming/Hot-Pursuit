
HotPursuitMaps = {}

HotPursuitMaps["rp_rockford_v2b"] = {
	[1] = { --Layout of the track
		Name = "Standard",
		Description = "Standard track layout around Rockford.",
		--[[ CarSpawns = { --Positions of the cars at the start of the race
			{ Vector( -6115, -6936, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -6115, -6699, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -5388, -6943, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -5379, -6694, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -4546, -6932, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -4559, -6690, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -3778, -6940, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -3791, -6698, 0 ), Angle( 0, 90, 0 ) }  --Disabled for now due to a game bug that prevents the angles of vehicles from being set
		},
		PoliceSpawns = { --Positions of the police cars at the start of the race
			{ Vector( -8876, -3464, 0 ), angle_zero },
			{ Vector( -9804, 3460, 7 ), Angle( 0, -90, 0 ) },
			{ Vector( -12557, 12723, 511 ), Angle( 0, -62, 0 ) },
			{ Vector( -2182, 8555, 543 ), Angle( 0, 90, 0 ) },
			{ Vector( 2685, 2950, 535 ), angle_zero },
			{ Vector( 10985, 5859, 1543 ), Angle( 0, -34, 0 ) },
			{ Vector( 4882, -11634, 320 ), Angle( 0, 160, 0 ) },
			{ Vector( -2811, 7976, 0 ), Angle( 0, -90, 0 ) }
		}, ]]
		BlockSpawns = { --Positions of the barriers that prevent racers from going off-course, each barrier has 2 extra barriers spawned on either side of it
			{ Vector( -2725, -6818, 0 ), angle_zero }, --Angle yaw must be either 0 or 90
			{ Vector( -3458, -6607, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -6704, -6527, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -9487, -3656, 0 ), angle_zero },
			{ Vector( -8758, -2367, 0 ), angle_zero },
			{ Vector( -9711, -2366, 0 ), angle_zero },
			{ Vector( -8877, 4995, 0 ), angle_zero },
			{ Vector( -9526, 6882, 0 ), angle_zero },
			{ Vector( -7033, 4995, 0 ), angle_zero },
			{ Vector( -6719, 4503, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -2588, 5363, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( -2589, 4620, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( -287, 4578, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 3071, 4553, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 2097, 5249, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 454, 4669, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 3074, 5394, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 7270, 4881, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 7266, 4124, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 9954, 4150, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 14048, 6810, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 5790, -12070, 320 ), angle_zero },
			{ Vector( -2770, -11868, 0 ), angle_zero },
			{ Vector( -2397, -2695, 0 ), Angle( 0, 90, 0 ) }
		},
		StartPos = { --Until the angles bug is fixed, players will have a physical line that they'll start behind
			Pos = Vector( -6240, -6815, 0 ),
			Ang = Angle( 0, 180, 0 )
		},
		FinishPos = { --Position of the finish line
			Pos = Vector( -2403, -3149, 1 ),
			Ang = Angle( 0, -90, 0 )
		}
	},
	[2] = {
		Name = "Reversed",
		Description = "Same as standard but the places of the starting line and finish line are swapped.",
		--[[ CarSpawns = {

		},
		PoliceSpawns = {

		}, ]]
		BlockSpawns = {
			{ Vector( -2725, -6818, 0 ), angle_zero },
			{ Vector( -3458, -6607, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -6704, -6527, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -9487, -3656, 0 ), angle_zero },
			{ Vector( -8758, -2367, 0 ), angle_zero },
			{ Vector( -9711, -2366, 0 ), angle_zero },
			{ Vector( -8877, 4995, 0 ), angle_zero },
			{ Vector( -9526, 6882, 0 ), angle_zero },
			{ Vector( -7033, 4995, 0 ), angle_zero },
			{ Vector( -6719, 4503, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -2588, 5363, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( -2589, 4620, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( -287, 4578, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 3071, 4553, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 2097, 5249, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 454, 4669, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 3074, 5394, 536 ), Angle( 0, 90, 0 ) },
			{ Vector( 7270, 4881, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 7266, 4124, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 9954, 4150, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 14048, 6810, 1536 ), Angle( 0, 90, 0 ) },
			{ Vector( 5790, -12070, 320 ), angle_zero },
			{ Vector( -2770, -11868, 0 ), angle_zero },
			{ Vector( -2397, -2695, 0 ), Angle( 0, 90, 0 ) }
		},
		StartPos = {
			Pos = Vector( -2403, -3149, 1 ),
			Ang = Angle( 0, -90, 0 )
		},
		FinishPos = {
			Pos = Vector( -6240, -6815, 0 ),
			Ang = Angle( 0, 180, 0 )
		}
	}
}

--[[ HotPursuitMaps["fightspace3b"] = { --Example of a free roam only map
	[1] = {
		Name = "Standard Free Roam",
		Description = "Standard track, free roam only.",
		FreeRoamOnly = true, --Whether the map only supports the free roam track type or not (this will usually be applied to open maps where a reasonable amount of barriers wouldn't be enough to prevent track cutting)
		StartPos = {
			Pos = Vector( 0, 0, 0 ),
			Ang = angle_zero
		}
	}
} ]]
