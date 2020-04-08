# Simply Potato (StepMania 5)

🥔🥔🥔🥔🥔🥔🥔🥔
======================

## About

Simply Potato is a StepMania 5 theme for the part of the post-ITG community that also happens to love potatoes.

It features a clean and simple design, offers numerous potato-driven features not implemented by the StepMania 5 engine, and allows the current generation of PIU fans to breathe new life into the game they've never played in years because we haven't had crap for DDR/ITG cabs up until now ;_;

Simply Potato SM5 is a fork of the original Simply Love SM5 theme that adds some visual tweaks and new features. It is intended for the Idaho Rhythm Group's new public DDR cab (thus why everything is potato themed), and as such is *heavily* geared towards use on our specific cabinet. It'll still work just fine for private use too, though!

Current major changes/tweaks:
  * Support for Stepmania 5.3 (currently barebones and WIP, should be stable but testing is needed)
  * An option for a potato-inspired visual style to go along with the other styles (hearts, arrows, thonk, etc)
  * New menu music options, independent of the visual style in use
  * Improvements to to memory card appearance and features, like different game style choice defaults for memory card and non-memory card users, among other minor visual tweaks
  * Tweaks to Casual Mode's music wheel (it now has a more standard cover flow-style look)
  * Tweaks to menu element positioning on the regular music wheel as well
  * Splash text on the title screen
  * Other visual changes and tweaks
  
Do note that while the original Simply Love theme was translated into several languages, Simply Potato (at the moment at least) only has English translations for the new lines of text. Expect errors if you're using a language other than English, sorry!

Thanks to quietly-turning, hurtpiggypig, and everyone else who helped with the original Simply Love themes for SM5 and SM3.95, directly or indirectly. Your help helped create the *de facto* Stepmania theme for multiple generations of dance game players, and no other theme I've seen has compared to the amount of polish and *love* that was put into the original themes.



## Requirements

You'll need to install [StepMania 5.0.12](https://github.com/stepmania/stepmania/releases/tag/v5.0.12), [StepMania 5.1 beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2), or [StepMania 5.3](https://projectmoon.dance/index.php?id=2) to use this theme.

Older versions of StepMania are not compatible.  StepMania 5.2 is not compatible. StepMania 5.3 support is currently experimental but should in theory be stable.

#### Troubleshooting StepMania

If you are having trouble installing StepMania or getting it to run on your computer, please refer to StepMania's [FAQ](http://www.stepmania.com/faq/).  Additionally, you may find these links helpful for your given operating system:

  * **Windows** -  [This issue on GitHub](https://github.com/stepmania/stepmania-site/issues/64) provides links to the needed DirectX and VS2013 redistributable packages.
  * **macOS** - If you are unable to open the dmg installer with an error like "No mountable file systems", you'll need to [update your copy of macOS](https://github.com/stepmania/stepmania/issues/1726) for the time being. If you are encountering the "No NoteSkins found" error, [this wiki page](https://github.com/stepmania/stepmania/wiki/Installing-on-macOS) provides a means of resolving it on your computer until it is properly fixed upstream.
  * **Linux** - It is more or less assumed that you will build your own executables if you are using Linux.  StepMania's GitHub wiki provides both a [list of dependencies](https://github.com/stepmania/stepmania/wiki/Linux-Dependencies) and some [instructions on compiling](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania).


## Installation

Head to the [Releases Page](https://github.com/48productions/Simply-Potato-SM5/releases) to download the most recent formal release of Simply Potato. But not really. We haven't bothered to make one of those yet. Downloading directly from the *master* branch is the way to go for now.

To install this theme, unzip it and move the resulting directory inside the *Themes* folder in your [StepMania user data directory](https://github.com/stepmania/stepmania/wiki/User-Data-Locations). Note that the *Themes* folder has been moved into the *Appearance* folder in StepMania 5.3.

## Screenshots

Visit quietly-turning's imgur album for screenshots of the original Simply Love SM5 theme in action: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)

## New Features

Or, *things quietly-turning has added that were not present in the original Simply Love for StepMania 3.95.*

#### New GameModes

* [Casual](http://imgur.com/zLLhDWQh.png) – Intended for novice players; restricted song list, no failing, no LifeMeter, simplified UI, etc.  You can read more about customizing what content appears in Casual Mode [here](./Other/CasualMode-README.md).
* [ITG](http://imgur.com/HS03hhJh.png) – Play using the *In the Groove* standards established over a decade ago
* [FA+](http://imgur.com/teZtlbih.png) – Similar to ITG, but features tighter TimingWindows; can be used to qualify for ECFA events
* [StomperZ](http://imgur.com/dOKTpVbh.png) – Emulates a very small set of features from Rhythm Horizon gameplay

#### New Auxiliary Features

  * [Live Step Statistics](https://imgur.com/w4ddgSK.png) – This optional gameplay overlay tracks how many of each judgment have been earned in real time and features a notes-per-second density histogram.  This can make livestreaming more interesting for viewers.
  * [Judgment Scatter Plot](https://imgur.com/JK5Li2w.png) – ScreenEvaluation now features a judgment scatterplot where notes hit early are rendered "below the middle" and notes hit late are rendered "above the middle." This can offer insight into how a player performed over time. Did the player gradually hit notes earlier and earlier as the song wore on? This feature can help players answer such questions.
  * [Judgment Density Histogram](https://imgur.com/FAuieAf.png) – The evaluation screen also now features a histogram that will help players assess whether they are more often hitting notes early or late.
  * [Per-Column Judgment Breakdown](https://imgur.com/ErcvncM.png)
  * [IIDX-inspired Pacemaker](http://imgur.com/NwN8Fnbh.png)
  * [QR Code Integration with GrooveStats](https://imgur.com/olgg4hS.png) – Evaluation now displays a QR code that will upload the score you just earned to your [GrooveStats](http://groovestats.com/) account.
  * Improved MeasureCounter – Stepcharts can now be parsed ahead of time, so it is no longer necessary to play through a stepchart at least once to acquire a stream breakdown.

#### New Aesthetic Features
 * [RainbowMode](http://i.imgur.com/aKsvrcch.png) – add some color to Simply Love! Why pick *one* color when you can pick *all the colors*?
 * [NoteSkin and Judgment previews](https://imgur.com/QUSqxr8.png) in the modifier menu
 * Improved widescreen support

#### New Conveniences for Public Machine Operators
  * [MenuTimer Options](http://imgur.com/DPffsdQh.png) – Set the MenuTimers for various screens.
  * [Long/Marathon Song Cutoffs](http://i.imgur.com/fzNJDVDh.png) – The cutoffs for songs that cost 2 and 3 rounds can be set in *Arcade Options*.

#### Language Support

Simply Potato has support for:

  * English
  * ~~Español~~
  * ~~Français~~
  * ~~Português Brasileiro~~
  * ~~日本語~~
  * ~~Deutsch~~

*(Simply Love SM5 is translated into the above languages, but Simply Potato's additions are yet to be translated)*

If, for some reason, you want to help translate Simply Potato's additional menu options, leave a comment in [this issue](https://github.com/48productions/Simply-Potato-SM5/issues/3) or submit a pull request.

The current language can be changed in Simply Potato under *System Options*.  You may need to restart StepMania immediately after changing the language for all in-game text to be properly translated.


---

## FAQ

#### Why are my high scores ranking out of order?
You need to set `PercentageScoring=1` in your Preferences.ini file.  Please note that you must quit StepMania before opening and editing Preferences.ini.

Your existing scores will remain ranked out of order, but all scores going forward after making this change will be ranked correctly.

#### Where is my Preferences.ini file?
See the [Manually Changing Preferences](https://github.com/stepmania/stepmania/wiki/Manually-Changing-Preferences) page on StepMania's GitHub Wiki.

#### How can I get more songs to show up in Casual Mode?
Please refer to the [Casual Mode README](./Other/CasualMode-README.md).

#### Why potatoes?
Why not? 🥔

