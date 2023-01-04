# About News

News is an optional feature of Simply Spud that displays custom images during attract mode, optionally to players as well.

Use this to show info about new content, events, etc. Great for public cab usage!

---

## Making images

 - Place images to show in `Other/News/`
 - Filename doesn't matter much, you'll just specify it in the config later
 - Transparent images are allowed - everything is displayed over the normal "flying icons" background

---

## Configuring News

 To configure the news feature, edit `Other/News/news.ini`.
 
 Add news entries to show in the following format:
 ```
# You can preface lines with a `#` to comment them out
[ID]
File=
StartDate=
EndDate=
ShowToPlayer= (Optional)
DisableAttractShow= (Optional)
 ```
 
 
 - `[ID]` - The ID of this news entry, must be a number. Higher IDs are given higher priority when finding news to display.
 - `File` - The image file to show, located in `Other/News/`
 - `StartDate` - This news entry will not be shown before this date. Format as `MM/DD/YYYY` (i.e. `02/15/2021`).
 - `EndDate` - This news entry will not be shown after this date, format same as StartDate.
 - `ShowToPlayer` (Optional) - If set to true, this news entry will be shown to Pro Mode players with a memory card in-game as well. Omit this field entirely to only show this entry in attract mode.
 - `DisableAttractShow` (Optional) - If set to true, this news entry will not be shown in attract mode. Omit this field entirely to show this entry in attract mode


### Finding News to Show

 When finding news to show, Simply Spud will search for news entries this way:
 
 - Higher IDs are checked first (location in the news.ini file doesn't matter), the first valid entry found is what's used
 - Skipping news IDs (i.e. your entries have IDs of 1, 2, 5) is known to be broken and is unsupported.
 - An entry isn't used if the ID isn't a number, the specified file isn't found, or if the date isn't formatted correctly in the config
 - Entries with a start date after the current date or an end date before the current date aren't used.


There are two locations ingame that news can be shown in:

Attract Mode: The highest news entry (if any) that meets the above criteria is shown in the attract loop by default unless that entry has DisableAttractShow set.
During Mode Selection: The highest news entry (if any) that meets the above criteria AND has ShowToPlayer enabled will be shown to players in Pro Mode just before entering the music wheel. Players with a memory card will only see this entry once, and never again.