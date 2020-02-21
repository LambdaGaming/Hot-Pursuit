
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

HP_CONFIG_MUSIC_VOLUME = 0.5 --Volume percentage of the music as a decimal, 0.5 is 50% and 1 is 100%

HP_CONFIG_BLACKLIST = { --Blacklisted vehicle models that players can't spawn
	--["models/vehicles/example.mdl"] = true --Example restriction
}

HP_CONFIG_VEHICLE_CLASSES = { --Classes of vehicles that players are allowed to spawn
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_airboat"] = true,
	["gmod_sent_vehicle_fphysics_base"] = true --Simfphys support, might need changed since the wheels count as separate entities
}

HP_CONFIG_PISTOLS = { --Pistols to randomly pick from on the hardcore mode
	["weapon_pistol"] = true
}

HP_CONFIG_RIFLES = { --Rifles to randomly pick from on the nightmare mode
	["weapon_smg1"] = true,
	["weapon_ar2"] = true
}

--Advanced config, don't touch anything here unless you know what you're doing.
--Changing values here won't do much unless you change the core code to reflect your changes here.
HP_CONFIG_TRACK_TYPES = { --Allows admins to change whether racers are confined to a track or not
	[1] = {
		Name = "Standard",
		Description = "Barriers are spawned, racers are confined to a path."
	},
	[2] = {
		Name = "Free Roam",
		Description = "Barriers and finish line don't spawn, racers are free to drive anywhere on the map, time limit is always enabled."
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