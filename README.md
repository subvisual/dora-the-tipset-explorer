# Dora, the TipsetExplorer

This a project part of the [Space Warp hackathon by ETHGlobal](https://ethglobal.com/events/spacewarp).

## Installation

Run `bin/setup` to install the necessary dependencies for the project to work. It will also setup you up with a Postgres Database. 

After the setup, just do `bin/server` and you should be good to go!

## Generating a new Indexer App

This part is still being handled in the `zdv/dora-installer` branch.

## Generating new Event Handlers




## Start indexing new Smart Contracts

Type `Dora.start_explorer_instance("0x1234", abi_path)`, with a valid address and ABI, to start exploring this Smart Contract.

For this to work when deploying the App, make sure that the ABI(s) are accessible within the server.

**NOTE**: the file `addresses` keeps track of the messages that it has indexed already, by smart contract. This way, if you stop and re-run the server, it will resume from where it stopped, and not from the begining (if you want to replay stuff locally, just delete the file entirely -> a new one is created automatically).

To stop an address from being indexed, you can also do `Dora.stop_explorer_instance(address)`.

## Next Steps
