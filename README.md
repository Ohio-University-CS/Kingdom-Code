# Kingdom-Code
 
## Project Description
A fun, interactive learning tool designed to help programming beginners learn coding concepts through gameplay.
 
Example Video
![Watch the video](ReadMeVideos/Level3.mp4)
 
---
 
## Features
- Interactive gameplay for learning programming basics  
- Beginner friendly design such as block code  
- Playable online or downloadable  
 
---
 
## Installation
1. Go to the GitHub repository  
2. Download the latest release 
 
---
 
## How to Run
Option 1 Play Online: https://arw0046.itch.io/kingdom-code 
Option 2 Download: https://github.com/Ohio-University-CS/Kingdom-Code/releases/tag/v1.0.0 
 
---
 
## Usage Examples

### Code Blocks Descriptions

Move Block
  Can use all 4 direction blocks and moves one block per use in each direction, Down and Up are used for climbing, can use the multiplier block

Dash Block
  Can use Left and Right blocks, can use multiplier, Dashes player up to 3 blocks left or right

Multiplier Block
  any block it is put on works as # amount of blocks, EX: moveRightx3 runs move right 3 times

Switch Block
  when over a lever it pulls the lever

Wait Block
 Waits one second before contenuing 

 
### Movement Mechanics
 
1. Move (Right, Left, Up, Down)
Format: [Move -> Direction]  
Description: Moves the player one tile in the chosen direction.
 
2. Move Multiplier (Right, Left, Up, Down)
Format: [Move -> Direction -> X]  
Description: Repeats the move action X times.
 
3. Dash (Right, Left)  
Format: [Dash -> Direction]  
Description: Moves the player forward by 3 tiles in the chosen direction, if there is a wall within 3 tiles, player will move forward until the wall.
 
4. Dash Multiplier (Right, Left)  
Format: [Dash -> Direction -> X]  
Description: Repeats the dash action X times.
 
### Actions
 
1. Switch (Activate Lever)  
Format: [Switch]  
Description: Activates a lever or switch in the level.
 
2. Wait 
Format: [Wait]  
Description: Skips a turn and pauses movement for 1 second.
 
### Extra
 
- Code blocks can be stacked to create longer sequences of actions.
 
---
 
## Known Issues
- Character sometimes gets stuck on stairs
- In some spots the character may be able to dash out of bounds
- Doors can sometimes break in the levels
 
---
 
## Future Work
- Add more levels and challenges  
- Improve graphics and UI design  
- Expand gameplay features (For loops and While loops) 
- Fix bugs 
 
---
 
## Contributors
- Mathew Goh: Level Designer & Visuals 
- Ben Edwards: Gameplay Programmer (Core Mechanics) 
- Alexander Williams: Systems & Gameplay Integration  
 
---
 
