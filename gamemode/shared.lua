
GM.Name 	= "Hot Pursuit"
GM.Author 	= "Lambda Gaming"
GM.Email 	= "N/A"
GM.Website 	= "N/A"
HP_VERSION = 0.5

DeriveGamemode( "sandbox" )

SetGlobalBool( "RaceStarted", false )
SetGlobalBool( "PreRace", false )
SetGlobalBool( "TrackType", 1 )
SetGlobalInt( "RaceMode", 1 )
SetGlobalInt( "TrackLayout", 1 )

TEAM_NONE = {
	ID = 1,
	Playermodel = {
		"models/player/Group01/Female_01.mdl",
		"models/player/Group01/Female_02.mdl",
		"models/player/Group01/Female_03.mdl",
		"models/player/Group01/Female_04.mdl",
		"models/player/Group01/Female_06.mdl",
		"models/player/group01/male_01.mdl",
		"models/player/Group01/Male_02.mdl",
		"models/player/Group01/male_03.mdl",
		"models/player/Group01/Male_04.mdl",
		"models/player/Group01/Male_05.mdl",
		"models/player/Group01/Male_06.mdl",
		"models/player/Group01/Male_07.mdl",
		"models/player/Group01/Male_08.mdl",
		"models/player/Group01/Male_09.mdl"
	}
}

TEAM_RACER = {
	ID = 2,
	Playermodel = {
		"models/player/Group03/Female_01.mdl",
		"models/player/Group03/Female_02.mdl",
		"models/player/Group03/Female_03.mdl",
		"models/player/Group03/Female_04.mdl",
		"models/player/Group03/Female_06.mdl",
		"models/player/group03/male_01.mdl",
		"models/player/Group03/Male_02.mdl",
		"models/player/Group03/male_03.mdl",
		"models/player/Group03/Male_04.mdl",
		"models/player/Group03/Male_05.mdl",
		"models/player/Group03/Male_06.mdl",
		"models/player/Group03/Male_07.mdl",
		"models/player/Group03/Male_08.mdl",
		"models/player/Group03/Male_09.mdl"
	}
}

TEAM_POLICE = {
	ID = 3,
	Playermodel = {
		"models/player/urban.mdl",
		"models/player/riot.mdl",
		"models/player/gasmask.mdl",
		"models/player/swat.mdl"
	}
}
