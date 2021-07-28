# Hot Pursuit
 Racing gamemode for Garry's Mod. Inspired by EA's Need For Speed: Hot Pursuit 2. Requires [Automod](https://github.com/LambdaGaming/Automod) to work properly.

## How it Works:
- Players can choose to race with or without police. Teams can be chosen by pressing F4.
- The goal of the police is to eliminate racers by wrecking their cars (or killing them in the harder modes) before they can cross the finish line. During the pre-race, police should hide along the track and wait for players to pass them.
- Players who don't choose a team will automatically be spectators. Teams cannot be changed during a race.
- Admins control races through a menu accessed by pressing F3. An optional timer can be toggled before starting a race. When the timer ends, the winners will be determined based on who all crossed the finish line. If the race has no timer, it will end once all racers have finished or have been elimiated.
- Once the race starts, the start and finish lines and barriers will be spawned. Barriers are placed around the track, usually at intersections, to guide players to the finish line. If a player passes through a barrier, it will alert everyone that unfair track cutting may be occuring.
- Admins can either choose to run the race as a closed course, a reversed closed course, or in free-roam mode. The free-roam mode racers to go wherever they want on the map. Because there is no finish line, the timer that is normally optional is required in free-roam mode.
- Admins can also choose between different race modes that allow players to use weapons and tools to slow down or stop their opponents.
- Multiple track layouts for each map are supported. Layouts can either be single lap races where the finish line is separate from the starting line, or multiple lap races where the start and finish lines are the same.
- Music will start playing as soon as the race countdown starts. Server developers can add tracks through the config. For copyright reasons, music is not included with the gamemode.
- Both [Automod](https://github.com/LambdaGaming/Automod), my own vehicle system, as well as vehicles running on [Simfphy's Lua Vehicles base](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490) are fully supported and will work together without issue. VCMod support may come in the future.

## Map Support:
 You can find the list of currently supported maps [here.](https://github.com/LambdaGaming/Hot-Pursuit/blob/master/maps.md)

 Due to the fact that I can't add support for every map on the workshop in any reasonable amount of time, I will only be adding support for maps that I feel will work the best. Any requests to add support to a map will be ignored by me. If you want to add support to a map yourself, I'll be happy to accept a PR as long as the map meets the following requirements:
1. Map must have at least 1 road. A road qualifies as a brush that sits on top of the main ground brush that is textured with a dirt, stone, gravel, concrete, asphalt, brick, or ice material. Main ground brushes can qualify as roads if the ground has an overlay of one of the previously mentioned materials.
2. If the map only has 1 road, that road has to loop back into itself. If the map has more than 1 road, the majority of them must connect to each other.
3. Map can't have any bugs or glitches that can be encountered on the track including but not limited to non-solid parts of the road, broken skyboxes, or broken map logic.
4. Road can't be open on either side unless there's no chance for racers to cut the track. (Excludes intersections and other road extensions since they can be blocked off with a reasonable amount of barriers. Also excludes areas that let players leave the track but ultimately funnels them back into it at the cost of falling behind in the race.)
5. Entire track must be wide enough to fit the Half-Life 2 jeep.

## Issues & Pull Requests
 If you would like to contribute to this repository by creating an issue or pull request, please refer to the [contributing guidelines.](https://lambdagaming.github.io/contributing.html)
