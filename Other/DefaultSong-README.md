# Configuring Default Songs

Simply Spud allows for a random default song to be picked for players without a profile on each new game cycle. No more listening to the first song in the first group all day, yay!

Unlike Simply Love, these defaults apply to all game modes (both Beginner and Pro).


## Setup

1. Create `DefaultSongs.txt` in this theme's `Other` folder
   * If Easter Eggs are enabled, you can also create `DefaultSongsAprilFools.txt` to use on April Fools day
2. Enter any number of songs, one per line, to the file in this format:

<SM Song Folder>/<Group>/<Song>

<SM Song Folder> - If you put your songs in `StepMania 5/Songs/`, this is `Songs`. If your songs are added via AdditionalFolders, this is probably `AdditionalSongs`.

<Group> - The group folder the song is in

<Song> - The song folder itself

Example:
`Songs/StepMania 5/Goin' Under` is a valid default song entry


## Notes

Invalid song titles/groups/etc are ignored.

Songs will not appear if:

 - You mispell/specify the wrong SM Song Folder (i.e. `Songs` instead of `AdditionalSongs`)
 - The song/group name is misspelled
 - In casual mode (and if CasualMode-Groups is in use), if the chosen default song for a game cycle isn't in the casual group whitelist, the first song in the first group is used instead.