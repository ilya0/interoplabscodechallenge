# interoplabscodechallenge

Please implement a smart contract for a tic-tac-toe game in your preferred smart contract VM (Solidity/EVM, Cosmwasm/Cosmos, Rust/Solana etc.). Rules will be at the end of this email. Don’t worry if you don’t complete it. We're mostly interested in how you approach a new challenge, which issues you faced along the way, how you design a solution, and how you think about its security. Send us whatever you have before the meeting and we can discuss your work during the tech interview.

Rules for tic-tac-toe:


* All state of the game should live on-chain. State includes open games, games currently in progress and completed games.

* Any user can submit a transaction to the network to invite others to start a game (i.e. create an open game).

* Other users may submit transactions to accept invitations. When an invitation is accepted, the game starts.

* The roles of “X” and “O” are decided as follows. The users' public keys are concatenated and the result is hashed. If the first bit of the output is 0, then the game's initiator (whoever posted the invitation) plays "O" and the second player plays "X" and vice versa. “X” has the first move.

* Both users submit transactions to the network to make their moves until the game is complete.

* The game needs to support multiple concurrent games sessions/players.

* Think about security for this contract (you can assume that this contract is upgradable for this question). How would you audit it, create a threat model, deploy and maintain operations for it?