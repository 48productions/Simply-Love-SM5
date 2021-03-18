# About News

News is an optional feature of Simply Spud that displays custom images during attract mode, optionally to players as well.

Use this to show info about new content, events, etc. Great for public cab usage!

---

## Making images

 - Place images to show in `Other/News/`
 - Filename doesn't matter much, you'll just specify it in the config later
 - Transparent images are allowed - everything is displayed over the SL's normal "flying icons" background

---

## Configuring News

 To configure the news feature, edit `Other/News/news.ini`.
 
 Add news entries to show in the following format, preface lines with `#` to comment them out:
 ```
[ID]
File=
StartDate=
EndDate=
ShowToPlayer= (Optional)
 ```
 
 
 - `[ID]` - The ID of this news entry, must be a number. Higher IDs are given higher priority when finding news to display. Described more in the next section.
 - `File` - The image file to show, located in `Other/News/`
 - `StartDate` - This news entry will not be shown before this date. Format as `MM/DD/YYYY` (i.e. `02/15/2021`).
 - `EndDate` - This news entry will not be shown after this date, format same as StartDate.
 - `ShowToPlayer` (Optional) - If present and not set to "false"/0, this news entry will be shown to memory card users as well, omit this field to only show in attract mode. Described more in the next section.


### Finding News to Show

 When finding news to show, Simply Spud will search for news entries this way:
 
 - Higher IDs are checked first (location in the file doesn't matter), the first valid entry found is what's used
 - Skipping news IDs (i.e. your entries have IDs of 1, 2, 5) is known to be broken and is unsupported.
 - An entry isn't used if the ID isn't a number, the specified file isn't found, or if the date isn't formatted correctly in the config
 - Entries with a start date after the current date or an end date before the current date aren't used.


When showing news to a player:

 - The ShowToPlayer field must be present and the player can't have already seen a news entry with an equal or higher ID (that way they don't see the same news multiple times)