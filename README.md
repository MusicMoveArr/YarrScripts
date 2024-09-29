# YarrScripts

A relatively simple download.sh script to grab everything (linux/script knowledge is required for usage)

I made this script because Lidarr, as probably a lot of people know is just a pain, or can be a pain to work with

I think the most annoying part of Lidarr is that it can/will delete music from our library

Plus there are a bezillion unmapped files that we can never map

Anyway, checkout the script and edit the paths as needed

# Features
1. Download music using StreamRip from an url-list
2. Cleanup live-music and cover.jpg and delete empty directories
3. Tag the music using OneTagger
4. Rename the music files using the OneTagger renamer
5. Convert the music to M4A using ffmpeg
6. use MusicMover to upgrade your existing music library

# Dependencies
https://github.com/MusicMoveArr/MusicMover

https://github.com/Marekkon5/onetagger

https://github.com/nathom/streamrip

## Arch
```
yay -S onetagger streamrip ffmpeg
```
