# README

## About the project







## Getting Started



0. If your cmd can't print Chinese character, use:

   ```cmd
   $chcp 65001
   ```

   Then, try running the program

1. start the program by running

   ```cmd
   $escript simple_chess
   ```

   It will let you choose a player from color yellow and color blue. For example, I choose "blue". 

   ```cmd
   Choose your player: [yellow or blue] blue
   ```

   Next it will print the initial 3x4 board. *See rules for details.* 

2. Pick a token to move

   we have 4 tokens: 王 将 相 子, different token have their own moving rules. Pick one by inserting the token index 

   ```
   Pick a chess to move: 1王 2将 3相 4子
   ```

3. Select and insert the row and column of new location. Where you would like that token move to. 

   The beginning index is start at index 1 instead of 0. 

4. After moving finish, if the game is not win, it's opponent's turn. 

5. When one player is win, the program exit. 

## Rules

- 子 zi: can only go straight. The blue one can only move to the right, and the yellow one can only move to the left. 
- 相 xiang:  can only go diagonal by 1 step. If the previous position is [x, y], the next move can only be [[x+1, y+1], [x+1, y-1], [x-1, y+1], [x-1, y-1]]
- 将 jiang: can only go top, bottom, left, right by 1 step.
- 王 wang: can go anywhere by 1 step. 
- If any movement is invalid, it will stop the program. 



### How to win the game

In order to win, the player need to fulfill any of these conditions below:

1. Eat the token 王wang of opponent. Eat other tokens can continue the game. 
2. The token 王wang from player go into opponent zone. If player choose blue, the opponent zone is at column 4. If player choose yellow, the opponent zone is at column 1.



## Reference



## TODO

- Interactive with frontend interface. 