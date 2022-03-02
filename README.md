# tgbot
- That tg() function in util.sh might've been inspired from [Samar](https://github.com/SamarV-121)

## Messy, huh?
This bot is written solely for my own use, thus the script is messy. However, let me break down the code.

In this repo there are a few files (and folders):
```bash
# Files
tgbot.sh            # Brain of the bot, main while loop resides here
util.sh             # Utility functions, such as tg(), update(), more functions may be added later
extra.sh            # Extra functions that doesn't really fit util.sh
modules_loader.sh   # Loads modules from modules folder

# Folders
modules             # Where modules resides, will be loaded by modules_loader.sh
```

Alright, let me break down each files.

### tgbot.sh
---
Here, I put my while loop to iterate through updates, case statements to handle commands and run all the modules, nothing much. Of course, we first source appropriate scripts to get stuffs ready as you can see on the first few lines.
```bash
# -- trimmed --
## Sourcing stuffs (Our functions, extra functions ans aliases, etc)
source util.sh
source extra.sh
source modules_loader.sh
# -- trimmed --
```

### util.sh
---
This file contains core functions that are used by tgbot.sh. They are:
- tg()
- update()
- more functions may be added later

#### Functions description
1. update(): This function is used to get updates from Telegram. It's the main function of the bot.
1. tg(): This is a multi-purpose function. It can be used to send messages, send stickers, etc.

### extra.sh
---
This file contains non-core functions and variables that doesn't really fit util.sh, I pretty much just shove them here. I won't bother documenting stuff there because I modify them a lot.

#### But wait, there's actually one function in this file that's worth noting here
*I know I'm the one that'll use this README in the future in case I forgot what are these stuffs fore anyway :P*
- round(): This function is used to round a number to a certain number of decimal places.
- Syntax:
```bash
round <number> <amount of decimal places>
# e.g round 1.23456789 2
# 1.23
```

### modules_loader.sh
---
*I have no idea why i created this in the first place but anyway...*

- This script will source scripts from modules folder and tgbot.sh will run the modules functions each time the while loop iterates. *Sounds useless? Well, because it is.*
- The sourced modules must have filename without spaces and weird chars that bash wouldn't allow for a function name. This is because modules loader will assume the function name as the filename without the extension. Example of acceptable script:
```bash
#!/bin/bash
# Filename: module_name.sh
module_name() {
    case $RET_LOWERED_MSG_TEXT in
        '.foo'*)
            tg --replymsg "$RET_CHAT_ID" "$RET_MSG_ID" "hi"
            ;;
    esac
}
```
