
HP_CONFIG_RACE_TIMER = 600 --How long the race lasts in seconds, vehicles who haven't crossed the finish line by the time

HP_CONFIG_FINISH_TIMER = 120 --How much time racers have in seconds to reach the finish line after the first racer finishes before the race ends

HP_CONFIG_MUSIC_LIST = { --[COMING SOON] List of music that the game will randomly play when a race starts
	"temp.wav"
}

HP_CONFIG_BLACKLIST = { --Blacklisted vehicle models that players can't spawn
	--["models/vehicles/example.mdl"] = true --Example restriction
}

HP_CONFIG_VEHICLE_CLASSES = { --Classes of vehicles that players are allowed to spawn
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_airboat"] = true,
	["gmod_sent_vehicle_fphysics_base"] = true --Simfphys support
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