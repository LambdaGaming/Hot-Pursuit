# Hot Pursuit
 WIP racing gamemode for Garry's Mod. Inspired by EA's Need For Speed: Hot Pursuit 2.

## Current Features:
- Race with or without police. Players can choose their team by pressing F4.
- The goal of the police is to eliminate racers by wrecking their cars before they can cross the finish line.
- Players who don't choose a team will be spectators. Teams cannot be changed during a race.
- Admins can either choose to run the race as a closed course or in free-roam mode. The free-roam mode removes all barriers and allows racers to go wherever they want on the map. The timer that is normally optional is required in free-roam as the finish line is removed.
- Music support. Music starts playing as soon as the race countdown starts. Server developers can add or remove tracks through the config.
- Support for both Automod, my own (currently unreleased) vehicle system, as well as VCMod.
 
## Map Support:
Eventually I hope to have at least 2 track layouts for every popular map on the workshop. For now though, I compiled a list of maps I plan on supporting, a list of maps that are currently supported, and a list of maps that I won't be supporting. You can find these lists in the [maps.md file](https://github.com/LambdaGaming/Hot-Pursuit/blob/master/maps.md) of this repository.
  
I'll take map suggestions but I'll only add full support to maps that meet the following requirements:
- Map must have at least 1 road. A road qualifies as a brush textured with a dirt, gravel, concrete, asphalt, brick, or ice material or overlay that is completely free of any obstructions.
- If the map only has 1 road, that road has to loop back into itself. If the map has more than 1 road, none of the roads have to loop as long as they can be accessed via other roads.
- Map must be free of any glitches or other mechanics that may affect vehicles. (Examples: A non-solid road brush or deep displacement that can get vehicles stuck. A broken skybox that makes it difficult to see. A map event that breaks/obstructs the road.)
- Road can't be open on either side unless there's no chance for racers to cut the track. (Excludes intersections and other road extensions since they can be blocked off with a reasonable amount of barriers.)
- Road must be wide enough to fit the Half-Life 2 jeep without the wheels going outside of the road.
