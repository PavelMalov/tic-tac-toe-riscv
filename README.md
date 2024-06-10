# Tic-Tac-Toe on RISC V in RARS Emulator 🎮🖥️

## Overview

This project implements a classic Tic-Tac-Toe game on the RISC V architecture, running in the RARS (RISC-V Assembler and Runtime Simulator) emulator. The game features a simple interface and is controlled via keyboard inputs.

## Features ✨

- Classic Tic-Tac-Toe rules
- Two-player mode on a single device 👥
- Keyboard navigation with `w`, `s`, `a`, and `d` keys ⌨️
- Cell selection and marking with `Enter` ✔️
- Game restart with `r` 🔄
- Victory indication with the winning symbol (X or O) 🏆

## Getting Started 🚀

### Prerequisites

To run the game, you will need:
- RARS emulator: Download and install from [RARS GitHub](https://github.com/TheThirdOne/rars)
- Enable `Keyboard and Display MMIO Simulator` and `BitmapDisplay` from the `Tools` menu in RARS

### Running the Game

1. Clone the repository:
   ```sh
   git clone https://github.com/PavelMalov/tic-tac-toe-riscv.git
   ````
2. Open the RARS emulator.
3. Load the Tic-Tac-Toe program file ('tic_tac_toe.asm') into RARS.
4. Enable the required tools:
- Keyboard and Display MMIO Simulator
- BitmapDisplay

Settings for BitmapDisplay:
- Unit Width in Pixels: 4
- Unit Height in Pixels: 4
- Display Width in Pixels: 256
- Display Height in Pixels: 256
- Base Address for Display: 0x10040000 (heap)
5. Run the program in RARS.

### How to Play 🎲
1. **Navigation**: Use the 'w', 's', 'a', and 'd' keys to move the green highlight around the game board.
2. **Marking a Cell**: Press 'Enter' to place your mark (X or O) in the selected cell.
3. **Restarting the Game**: Press 'r' to restart the game at any time.
4. **Exiting the Game**: Press 'Q' to exit the game.
5. **Victory and Draw**:
- If a player wins, the winning symbol (X or O) will be displayed on the screen.
- Press 'r' to start a new game after a victory.
- If the game ends in a draw, it will automatically restart.

### Planned Features 🔮
- Implement a single-player mode where you can play against the computer 🤖.
