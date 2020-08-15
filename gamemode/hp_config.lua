
HP_CONFIG_PRERACE_TIMER = 3 --How long in seconds before the race starts after the command is sent to start it

HP_CONFIG_RACE_TIMER = 600 --How long the race lasts in seconds, vehicles who haven't crossed the finish line by the time

HP_CONFIG_FINISH_TIMER = 120 --How much time racers have in seconds to reach the finish line after the first racer finishes before the race ends

HP_CONFIG_MUSIC_LIST = { --List of music that the game will randomly play when a race starts
	"hotpursuit/track1.mp3",
	"hotpursuit/track2.mp3",
	"hotpursuit/track3.mp3",
	"hotpursuit/track4.mp3",
	"hotpursuit/track5.mp3",
	"hotpursuit/track6.mp3",
	"hotpursuit/track7.mp3",
	"hotpursuit/track8.mp3"
}

HP_CONFIG_BLACKLIST = { --Blacklisted vehicle models that players can't spawn
	--["models/vehicles/example.mdl"] = true --Example restriction
}

HP_CONFIG_PISTOLS = { --Pistols to randomly pick from on the hardcore mode
	"weapon_pistol"
}

HP_CONFIG_RIFLES = { --Rifles to randomly pick from on the nightmare mode
	"weapon_smg1",
	"weapon_ar2"
}

HP_CONFIG_BEACON_TIME = 30 --Time in seconds that each beacon lasts after being placed

HP_CONFIG_MINE_RANGE = 30 --Range in hammer units of the mines

HP_CONFIG_MINE_MAGNITUDE = 50 --Magnitude of the mines, includes both damage and physics forces

HP_CONFIG_RACES_UNTIL_MAP_CHANGE = 1 --Number of races that need to be completed before the map changes automatically; set to 0 to disable

HP_CONFIG_ONLY_SUPPORTED_MAPS = false --Whether or not the random map chooser should only look for officially supported maps

--Advanced config, don't touch anything here unless you know what you're doing.
--Changing values here won't do much unless you change the core code to reflect your changes here.
HP_CONFIG_VEHICLE_CLASSES = { --Classes of vehicles that players are allowed to race with
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_airboat"] = true,
	["gmod_sent_vehicle_fphysics_wheel"] = true, --Simfphys support
}

HP_CONFIG_TRACK_TYPES = { --Allows admins to change whether racers are confined to a track or not
	[1] = {
		Name = "Standard",
		Description = "Barriers are spawned, racers are confined to a path."
	},
	[2] = {
		Name = "Free Roam",
		Description = "Barriers and finish line don't spawn, racers are free to drive anywhere on the map, time limit is always enabled."
	},
	[3] = {
		Name = "Reversed",
		Description = "Same as standard but the start/finish lines are swapped places."
	}
}

HP_CONFIG_RACE_MODES = { --Allows admins to change how the races are run
	[1] = {
		Name = "Normal",
		Description = "Players cannot exit vehicles until the race is over."
	},
	[2] = {
		Name = "Advanced",
		Description = "Players can exit their vehicles and attempt to win the race on foot but can be stopped by police with tazers.",
		UseSpikestrip = true --Whether cops should spawn with spikestrips or not, either Automod or VCMod must be on the server for this to work
	},
	[3] = {
		Name = "Hardcore",
		Description = "Players can exit their vehicles and use pistols to try to slow down the police. Car health is reduced by 25%.",
		UseSpikestrip = true,
		UseBeacons = true --Whether cops should spawn with beacons or not
	},
	[4] = {
		Name = "Nightmare",
		Description = "Players can exit their vehicles and use rifles to try to slow down the police. Car health is reduced by 50%.",
		UseSpikestrip = true,
		UseBeacons = true,
		UseMines = true --Whether cops should spawn with mines or not
	}
}

HP_CONFIG_SUPPORTED_MAPS = { --List of supported maps; used by the random map chooser
	"rp_rockford_v2b",
	"rp_evocity2_v5p",
	"rp_florida_v2",
	"rp_truenorth_v1a",
	"rp_newexton2_v4h",
	"gm_bigcity",
	"gm_bluehills_test3",
	"gm_flatgrass_abs_v3c",
	"gm_fork",
	"gm_functional_flatgrass3",
	"gm_genesis",
	"gm_mobenix_v3_final",
	"rp_rockford_open",
	"rp_southside"
}
