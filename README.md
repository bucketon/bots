# bots

Instructions to run the game:
-----------------------------
1. Go to http://love2d.org and download the version of love2d for your operating system.
2. Download the latest release [here](https://github.com/bucketon/bots/raw/master/Release/Bots.love).
3. Drag Bots.love onto the Love2d application.

Version History:
----------------
**0.6.0**
* Added options menu with option to switch to 2x resolution and option to delete save
* Added 2 new puzzles

**0.5.0**
* Fixed interaction between EMP and Flayer
* Made the AI stop printing excessive logs
* Made the menu uglier and more useful
* Added Sandbox mode for trying things out
* Added Survival mode against the AI
* Added Puzzle mode
* Made enemy bots look slightly more distinct

**0.4.0**
* Refactored board to be better encapsulated (this shouldn't affect gameplay at all, so let me know if you notice any discrepancies).
* Wrote a random inputs test mode to automatically find crashes (again, you shouldn't notice anything from this addition.
* Improved AI significantly (it now wins \~65-70% of the time against a random player).
* Added sprite for neutral bot wins game end state.
* Added winrate tracking. wins are expressed through a score on the title screen. It is calculated for your last 100 games, with more recent games weighted more prominently.

**0.3.0**
* Fixed spybot art going off of the card
* Made floating card move around less
* Added ux for selecting a space before a card
* Added rules page
* Made board tiles easier to read regardless of orientation
* Added a menu to the title screen for choosing each view
* Added information about player turns to the game log for debugging
* Made a (hopefully) better shadow graphic now that it actually moves around
* Fixed lockout when neutral bot wins

**0.2.0**
* Added version numbers to the filename
* Disabled the console on release versions
* Added crash reports to the game log
* Changed “place” and “drop” to better words
* Added a floating animation for currently selected card
* Added arrow key instruction text
* Made X go to the hand if on board
* Added opponents hand as facedown cards at top of screen
* Checked Jade's spybot bug report (could not reproduce, not to say it wasn’t real, I think I fixed it inadvertently with the logging stuff)
* Added game log to help with reporting issues. The location varies depending on OS. See https://love2d.org/wiki/love.filesystem
* Added visual feedback on board for emp and booster
* Added indicator for next bot to attack
* Moved highlighted hand cards up a bit more
* Fixed a bug where pressing “down” while in the hand would move the cursor chaotically

Current Backlog:
----------------
View planned work [here](https://github.com/bucketon/bots/issues)
