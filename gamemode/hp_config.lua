
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

HP_CONFIG_RACE_MODES = { --[COMING SOON] Will allow admins to change how the races are run
	[1] = {
		Name = "Normal",
		Description = "Players cannot exit vehicles until the race is over."
	},
	[2] = {
		Name = "Advanced",
		Description = "Players can exit their vehicles and attempt to win the race on foot but can be stopped by police with tazers."
	},
	[3] = {
		Name = "Hardcore",
		Description = "Players can exit their vehicles and use pistols to try to slow down the police. Car health is reduced by 25%."
	},
	[4] = {
		Name = "Nightmare",
		Description = "Players can exit their vehicles and use rifles to try to slow down the police. Car health is reduced by 50%."
	}
}