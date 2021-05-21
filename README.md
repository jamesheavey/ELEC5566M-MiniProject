# ELEC5566M-MiniProject: Flappy Bird 

This repository contains multiple Verilog HDL files that program a DE1-SoC development board FPGA circuit to play the classic iOS game Flappy Bird. The full list of module hierarchy, properties and functions can be seen in sections below.

A video demonstration of the implemented code can be seen using the link provided:
[VIDEO DEMO](https://github.com/jamesheavey/ELEC5566M-MiniProject/blob/a439031b16155f7b8fb6ea56d151d74727cb6980/demo%20&%20diagrams/Video%20Demo.mp4)

## Module List
This repository includes the following files:

| MODULE | FUNCTION |
| ---  | --- |
| `flappy_bird.v`         |  Top-level module to interface with the DE1-SoC input and output ports. This module instantiates lowere level modules to perform the game logic operations.  |
| `vga_gen.v`             |  This module outputs the relevant VGA signal as well as the current update pixel coordinates (X,Y). These coordinates are used by the image renderer to time sprite display.  |
| `keyboard_input.v`      |  This module reads the output from a connected PS2 keyboard and decodes the signal into 2 user inputs. |
| `clk_divider.v`         |  This module takes a clk signal and an integer as a parameter and outputs a clk frequency at a lowere, divided frequency. This is used to create desireable clocks for use in many submodules. |
| `game_FSM.v`            |  This module defines the current game state and transitions based on user inputs or game events. The current game state is output to determine functions within other modules.  |
| `bird_physics.v`        |  This module defines the motion of the bird character, aiming to simulate motion under gravity. The bird Y coordinate is output for use in image rendering and collision. |
| `collision_detection.v` |  This module uses the current bird and pipe coordinates to determine if any sprites overlap. if they do, collision goes high.  |
| `pipes.v`               |  This module creates and moves the pipe obstacles for the game. The number and separation of pipes are defined as input params. The pipes are shifted left on each clock cycle. |
| `score_display.v`       |  This module tracks the current score and hiscore, transforming them to BCD for display on the screen and 7 segments.  |
| `image_rendering.v`      |  This module outputs a 24-bit RGB pixel colour at every VGA clk cycle. The colour is selected via logic using the VGA pixel coordinates (X,Y), the object positions and sizes, and the display priority of each sprite.  |
| `bin_to_BCD.v`          |  This is a submodule, instantiated in the `score_display` module to convert the binary value stored in the score register to a BCD value using 'shift-add-3'. |
| `hex_to_7seg.v`         |  This is a submodule, instantiated in the `score_display` module to convert the BCD score value into the 7segment representation of each unit. |
| `key_filter.v`          |  This is a submodule, instantiated in the `keyboard_input` module to positively edge detect user input key presses.  |
| `random_number_gen.v`   |  This is a submodule, instantaied in the `pipes` module to generate a 32bit random number to randomise the pipe obstacles. This module utilises an LFSR and was imported fron NANDLAND (REF: https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html) |

## Module Hierarchy
<p align="center">
  <img width="802" height="422" src="https://github.com/jamesheavey/ELEC5566M-MiniProject/blob/13cc6d2a150b8bd8d3835f4e10c6efe046054e8e/demo%20&%20diagrams/Module%20Hierarchy.png">
</p>

## Game FSM
<p align="center">
  <img width="569" height="451" src="https://github.com/jamesheavey/ELEC5566M-MiniProject/blob/5107396a15a4ae5640b25097c3d6883323959874/demo%20&%20diagrams/Game%20State%20FSM.png">
</p>

## Bird Motion FSM
<p align="center">
  <img width="649" height="451" src="https://github.com/jamesheavey/ELEC5566M-MiniProject/blob/a439031b16155f7b8fb6ea56d151d74727cb6980/demo%20&%20diagrams/Bird%20Motion%20FSM.png">
</p>

## Sprite Sheet
<p align="center">
  <img width="352" height="270" src="https://github.com/jamesheavey/ELEC5566M-MiniProject/blob/5107396a15a4ae5640b25097c3d6883323959874/demo%20&%20diagrams/Sprites.png">
</p>

All sprites originally from The Spriters Resource website (REF: https://www.spriters-resource.com/mobile/flappybird/sheet/59537/)

---

#### By James Heavey

#### SID: 201198933

#### University of Leeds, Department of Electrical Engineering
