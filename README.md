# Dora, the TipsetExplorer

This a project part of the [Space Warp hackathon by ETHGlobal](https://ethglobal.com/events/spacewarp).

## Installation

Run `bin/setup` to install the necessary dependencies for the project to work. It will also setup you up with a Postgres Database. 

After the setup, just do `bin/server` and you should be good to go!

Type `Dora.start_explorer_instance("0x1234")`, with a valid address, to start exploring it.

**NOTE**: the file `addresses` keeps track of the messages that it has indexed already, by smart contract. This way, if you stop and re-run the server, it will resume from where it stopped, and not from the begining (if you want to replay stuff, just delete the file entirely -> a new one is created automatically).
