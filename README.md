# Hot Pursuit
 Racing gamemode for Garry's Mod. Inspired by EA's Need For Speed: Hot Pursuit 2.

## Current Features:
- Race with or without police. Players can choose their team by pressing F4.
- The goal of the police is to eliminate racers by wrecking their cars before they can cross the finish line.
- Players who don't choose a team will be spectators. Teams cannot be changed during a race.
- Optional race timer that admins can toggle before starting a race. When the timer ends, the winners will be determined based on who all crossed the finish line.
- Admins can either choose to run the race as a closed course, a reversed closed course, or in free-roam mode. The free-roam mode removes all barriers and allows racers to go wherever they want on the map. The timer that is normally optional is required in free-roam as the finish line is removed.
- Different race modes that allow players to use weapons and tools to slow down or stop their opponents.
- Support for more than one track layout for each map. Layouts can either be single lap races where the finish line is separate from the starting line, or multiple lap races where the start and finish lines are the same.
- Music support. Music starts playing as soon as the race countdown starts. Server developers can add or remove tracks through the config.
- Support for both Automod, my own (currently unreleased) vehicle system, as well as vehicles running on Simfphy's Lua Vehicles base.

## Map Support:
 You can find the list of currently supported maps [here.](https://github.com/LambdaGaming/Hot-Pursuit/blob/master/maps.md)

 Due to the fact that I can't add support for every map on the workshop in any reasonable amount of time, I will only be adding support for maps that I feel deserve it the most. Any requests to add support to a map will be ignored. If you want to add support to a map yourself, I'd be happy to accept a PR as long as the map meets the following requirements:
- Map must have at least 1 road. A road qualifies as a brush that sits on top of the main ground brush that is textured with a dirt, stone, gravel, concrete, asphalt, brick, or ice material. Main ground brushes can qualify as roads if the ground has an overlay of one of the previously mentioned materials.
- If the map only has 1 road, that road has to loop back into itself. If the map has more than 1 road, none of the roads have to loop as long as they can be accessed via other roads.
- Map must be free of anything that may negatively affect players while driving. (Example: A non-solid road brush or deep displacement that can get vehicles stuck or a broken skybox that makes it difficult to see.) Road obstructions are allowed as long as they leave enough space for a vehicle the size of the HL2 jeep to get through.
- Road can't be open on either side unless there's no chance for racers to cut the track. (Excludes intersections and other road extensions since they can be blocked off with a reasonable amount of barriers. Also excludes areas that let players leave the track but ultimately funnels them back into it at the cost of a time loss.)
- Road must be wide enough to fit the Half-Life 2 jeep without the wheels going outside of the road.

## Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)
