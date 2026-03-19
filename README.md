# HFF Unity Files
## Description
This repository tracks the custom added files within my Unity 2017 template
project. It does not constitute a full Unity project on its own.

As of right now, this repository holds the files used to make the AssetBundles
for the following projects:

* [HFF Archipelago Client](https://github.com/Zman350x/HFF_ArchipelagoClient)

## Usage and Installation
To use this repository, please download Unity 2017.4.13 ([see here for help
installing on
Linux](https://discussions.unity.com/t/distributing-unity-with-flatpak-an-in-depth-analysis/1503606),
my comments on this post show how to get the 2017 version working) and follow
the first part of [this
guide](https://steamcommunity.com/sharedfiles/filedetails/?id=1619459875)
to setup the Human: Fall Flat workshop package.

To clone this repository into the existing project, first `cd` into the root of
the project (you should see the `Assembly-CSharp-Editor.csproj` and `<Project
Name>.sln` file, along with the `Assets`, `Library`, `ProjectSettings`, etc.
directories).

Run the following commands:
```bash
git init
git branch -m main
git remote add origin https://github.com/Zman350x/HFF_UnityFiles.git
git pull origin main
git branch --set-upstream-to=origin/main main
```
