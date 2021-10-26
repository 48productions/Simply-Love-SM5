# Configuring Casual Mode

Casual Mode provides a simplified StepMania experience for novice players.  It seeks to get new players playing the game faster by addressing many common stumbling points.

To summarize, Casual Mode:

  * restricts what song groups are available to choose from
  * filters out stepcharts above a given difficulty meter
  * provides a new, dedicated Select Music screen to simplify the process of choosing a song
  * provides more prominent on-screen instructions throughout
  * simplifies the flow of a game cycle by removing certain screens

Casual mode is currently left mostly unconfigured in Simply Spud - All groups are shown, and only stepcharts under difficulty 10 are shown. This is easily configured if you want a more fine-tuned casual mode setup, though!

## Filtering Stepcharts Above a Specific Difficulty Meter

By default, stepcharts with a difficulty meter greater than 10 will not appear in Casual Mode.  This threshold can be configured in the operator menu under *Simply Spud Options*.

If *all* stepcharts belonging to a given song are above that threshold, that song will not appear as a choice in the group it belongs to in Casual Mode.  If all stepcharts in a given group are above the threshold (I'm looking at you, Tachyon Epsilon), that entire group will not appear as a choice in Casual Mode.

## Restricting Song Groups in Casual Mode

Casual Mode makes use of a simple txt file to explicitly specify what song groups should be available in Casual Mode.  The file is titled **CasualMode-Groups.txt** and is located at *./Simply-Potato-SM/Other/CasualMode-Groups.txt*

Simply Potato ships with ~~28~~ no unique groups specified. For reasonable, trusted defaults, and if you are a machine operator looking for more novice content for your machine, you can start by adding [these packs from stock Simply Love's group lists!](https://github.com/quietly-turning/Simply-Love-SM5/blob/release/Other/CasualMode-Groups.txt)

Machine operators can customize this list as needed by adding (or removing) Groups by name, one per line.

If a group name is provided in that file that does not exist in the filesystem, it will be ignored.  If a group with no valid Casual Mode stepcharts is added to the list, that group will not appear as a valid choice.

If no groups are specified in this file (i.e., the file is empty), all packs with valid stepcharts will be available for play in Casual Mode.
