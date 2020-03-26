Simply Potato's file select menu can display a brief, user-supplied description of a song folder and its files' ratings in place of the empty ARTIST and BPM labels (in Group sort mode).  
This is mainly designed for cabinet owners who wish to help players understand the folder structure.  
For example, Ben Speirs' SPEIRMIX GALAXY could be given the description "Modern pop songs with background videos" and the ratings "ITG scale (1-14)."  

To quickly populate a folder of StepMania song packs with group info files, run the included GroupInfo-Creator script (Python 3).  
To do it manually, create an `info.ini` file in a song pack's folder with these contents:

```
[GroupInfo]
Description=Description goes here
Ratings=Rating info goes here
```

Note: If you have an info.ini in multiple folders with the same name (loaded with AdditionalFolders or AdditionalSongFolders), priority is given to the one in your StepMania installation's Songs folder.