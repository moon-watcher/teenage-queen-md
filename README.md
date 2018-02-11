# Teenage Queen For Megadrive

This is my megadrive port of the Atari ST game  made by ERE.

Reverse engineering was done by Foxy.

This is Alpha code ! Althought you can play, expect graphical glitches

![mockup](https://github.com/pascalorama/teenage-queen-md/blob/master/TQ-mockup.png)

How to play:
============
At the start of the game, every player has 100 chips.  Five cards are then 
dealt and then bidding begins!

The game is very simple to play. Use the joypad plugged into port #1 on the 
Genesis. Press left and right to to select a command (call, bet, raise, drop)
and then press A, B or C to confirm your selection. When changing cards, 
press the A or C button to select which cards to change, and then 
press the B button to receive your new cards.

Value of the cards: the order of the values is 7, 8, 9, 10, J, Q, K, A.  
There is rank in suits.  The rank of hands is as follows:

1) Pair (Two cards of the same numeric value)
2) Two pair (Two pairs of different numeric value)
3) Three of a kind (3 cards of same numeric value)
4) Straight (5 cards in numeric order)
5) Flush (5 cards of the same suit)
6) Full house (3 cards of same value and a pair of a different value)
7) Four of a kind (4 cards of same value)
8) Straight flush (5 cards in numeric order of the same suit)

Rules
=====
At the beginning of the game, before the cards are dealt, a first bet of 
5 chips is mandatory, which the game will automatically deduct from your stack.
This is known as the ante. Five cards are then dealt to the players. The player
who received the cards (the person who didn't deal) starts betting or stays, 
leaving betting to the opponent. When betting, a player can bet 5 to 25 chips. 
The opponent can give up immediatly (drop), bet an equal amount (call), or raise 
the bet by some amount (raise). Betting continues back and forth until both 
players call. At this point, new cards can be drawn. The numbers of cards you 
change can give your opponent an idea of your hand, so be wise. 
She might bluff you... ;)  

After the new cards are drawn, betting begins again as before with the same 
options: Drop if you feel that the risk is too high and your hand is lousy; 
Raise the pot to spice up the game, (and bluff your opponent); or call and 
equal the bet.  Once betting is completed, the cards are compared and the 
winner is awarded the pot.

Note:  If both players stay after the first cards are dealt, the hand is 
canceled and the bet remain in the pot. If both players stay after new cards 
are drawn, the players show their hands in order to find the winner.

Credits
=======
Developer : Pascal & Foxy

Special thanks goes to (in no particular order):
Foxy, Fonzie, Brian Peek, Tomy, Brandon Cobb, fr4nz, ZeGouky, Mariaud,
Michelle, Kaneda, WhiteSnake, Stef, Steve Snake, 
all the genesis dev. scene and the supporters of this project :)

THIS CODE IS NOT BE USE IN ANY COMMERCIAL PROJECTS WITHOUT MY WRITTEN CONSENT.

Teenage Queen (c) 1988 Ere

Please see http://www.pascalorama.com/teenage-queen/
