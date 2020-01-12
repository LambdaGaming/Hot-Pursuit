
HotPursuitMaps = {}

HotPursuitMaps["rp_rockford_v2b"] = {
	[1] = {
		Name = "Standard",
		Description = "Standard track layout around Rockford. Supports up to 16 players.",
		UseTimer = false,
		CarSpawns = { --Positions of the cars at the start of the race
			{ Vector( -6115, -6936, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -6115, -6699, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -5388, -6943, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -5379, -6694, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -4546, -6932, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -4559, -6690, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -3778, -6940, 0 ), Angle( 0, 90, 0 ) },
			{ Vector( -3791, -6698, 0 ), Angle( 0, 90, 0 ) }
		},
		PoliceSpawns = { --Positions of the police cars at the start of the race
			{ Vector( -8876, -3464, 0 ), Angle( 0, 0, 0 ) },
			{ Vector( -9804, 3460, 7 ), Angle( 0, -90, 0 ) },
			{ Vector( -12557, 12723, 511 ), Angle( 0, -62, 0 ) },
			{ Vector( -2182, 8555, 543 ), Angle( 0, 90, 0 ) },
			{ Vector( 2685, 2950, 535 ), Angle( 0, 0, 0 ) },
			{ Vector( 10985, 5859, 1543 ), Angle( 0, -34, 0 ) },
			{ Vector( 4882, -11634, 320 ), Angle( 0, 160, 0 ) },
			{ Vector( -2811, 7976, 0 ), Angle( 0, -90, 0 ) }
		},
		BlockSpawns = { --Positions of the barriers that prevent racers from going off-course

		},
		FinishPos = { --Position of the finish line
			Pos = Vector( -2403.28125, -3149.8125, 1.84375 ),
			Ang = Angle( 0, -90, 0 )
		}
	},
	[2] = {
		Name = "Single Racer Freeroam",
		Description = "Only 1 racer spawn, the rest of the players are cops. No barriers are spawned; the racer is free to drive anywhere until their car is fully damaged.",
		UseTimer = false,
		CarSpawns = {

		},
		PoliceSpawns = {

		},
		BlockSpawns = {

		},
		FinishPos = {

		}
	}
}