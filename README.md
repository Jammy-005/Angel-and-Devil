# COMP3821 Project - Angel and Devil (Group 32)
## Folders
### Windows
Contains executable, package and console files. All need to be downloaded and in the same directory. Run the executable.
### Mac
Contains a zip file with the entire codebase. Need to download Godot and import a new project with the unzipped file. Run the program through Godot.
### Linux
Contains the x86_64 executable and script files. All needed to be downloaded and in the same directory. Run the executable.
### Source
Contains the codebase. Structured into 2 scene trees, 1 for the game and 1 for a titlescreen containing adjustable configurations.
#### Game
- Game class handles the highest-level game logic and interactions between Tiles and the Angel. Controls game initialisation, turn management, scene changes and holds all Tiles in play.
- Angel class handles logic related to the Angel and the Tile it is currently on. Controls angel initialisation, drawing, movement, and pathfinding.
- Camera class handles all camera-related motions. Controls panning, zoom and supports redrawing for all relevant operations. Also provides a screen viewport.
- Tile class handles logic related to the Tile and between its neighbours. Controls tile initialisation, mouse click inputs, drawing, angel and devil sprites, lazy generation (possibly infinite) and tile shape creation.
#### Titlescreen
- TitleScreen class handles all interactions between menu items and the Game codebase. Controls adjacency input, size input, power input and scene changes.
- Global class handles all variables set by TitleScreen and used by Game, similar to a data class.
- Miscellaneous input classes connected directly to the TitleScreen for adjustable configurations.

## Development Timeline
Week 5: Tasked with creating a visualisation for the Angel and Devil Project. Researched various game engines (Godot, Unity, GameMaker, etc.) and methods to implement infinite procedural generation in all engines. Chose to develop the visualisation in Godot since research indicated it was the most beginner-friendly software to use (unlike Unity), and had a reasonable amount of supporting documentation and online resources to simplify debugging (unlike GameMaker).
Week 6: Attempted to code a general infinite procedural generation for all tesselations. Ultimately did not work due to major bugs:
- floating point errors (found after printing tile positions and receiving -0.0 instead of 0.0): fixed by snapping coordinates with a TOLERANCE constant of 1^(-100).
- inaccurate screen boundaries (found after printing tile positions and seeing tiles outside the visible screen were being generated): fixed after much trial and error with multiple displays and adjusting screen ratio until the screen rectangle drawn by the code matched the visible screen.
- generation of already generated tiles (found after printing tile positions and seeing duplicate coordinates): fixed after using the Game class to hold all tiles like a map, which the Tile class can access to check if the Tile it is about to generate already exists.

Week 7: Attempted to debug broken infinite procedural generation code for all tesselations. Simultaneously developed code for the Game logic, specifically Angel movement and Devil tile removal.
Week 8: Shrunk scope to infinite procedural generation of 4 adjacency tiles (ie. chessboard). Refactored codebase to force 4 adjacency tiles instead of general tesselations. Identified bugs listed in the Week 6 entry. Simultaneously developed code for the TitleScreen, specifically adjustable configurations so users did not need to change code constants directly for desired settings.
Week 9: Fixed all bugs listed in the Week 6 entry. Infinite procedural generation for the chessboard was now operational. Extended this to all other regular polygon tesselations (linear, triangular and hexagonal). Simultaneously developed graphics for Angel, Devil and Tiles, incorporating graphic management into the Tile class. 
Week 10: Added power functionality to angel movement, and graphics for Angel loss (Tombstone). Added finite maps, piggybacking off power code to generate finitely large games for all tessellations. Repaired buggy visuals with clipping Angel and Devil using the Tile's shape as a mask on the Angel, Devil and Tombstone sprites. Final release.
