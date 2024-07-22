// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Define the TicTacToe contract
contract TicTacToe {
    // Enum to represent the state of the game
    enum State { Open, InProgress, Completed }
    // Enum to represent the players in the game
    enum Player { None, X, O }

    // Structure to hold the details of a game
    struct Game {
        address initiator;         // Address of the game creator
        address acceptor;          // Address of the player who accepted the game
        Player[9] board;           // Array to represent the game board
        Player currentPlayer;      // Current player who is to make a move
        State state;               // Current state of the game
        address winner;            // Address of the winner
    }

    Game[] public games;  // Array to store all games
    mapping(address => uint256[]) public playerGames;  // Mapping to track games each player is involved in

    // Events to log game creation, acceptance, move, and completion
    event GameCreated(uint256 gameId, address initiator);
    event GameAccepted(uint256 gameId, address acceptor);
    event MoveMade(uint256 gameId, address player, uint8 position);
    event GameCompleted(uint256 gameId, address winner);

    // Function to create a new game
    function createGame() external {
        // Initialize a new game structure
        games.push(Game({
            initiator: msg.sender,
            acceptor: address(0),
            board: [Player.None, Player.None, Player.None, Player.None, Player.None, Player.None, Player.None, Player.None, Player.None],
            currentPlayer: Player.None,
            state: State.Open,
            winner: address(0)
        }));

        uint256 gameId = games.length - 1;  // Get the ID of the newly created game
        playerGames[msg.sender].push(gameId);  // Track the game for the initiator
        emit GameCreated(gameId, msg.sender);  // Emit event for game creation
    }

    // Function to accept an open game
    function acceptGame(uint256 gameId) external {
        Game storage game = games[gameId];  // Get the game by ID
        require(game.state == State.Open, "Game is not open for acceptance");  // Ensure the game is open
        require(game.initiator != msg.sender, "Initiator cannot accept their own game");  // Ensure the initiator does not accept their own game

        game.acceptor = msg.sender;  // Set the acceptor of the game

        // Determine roles based on the hash of the initiator and acceptor addresses
        bytes32 hashed = keccak256(abi.encodePacked(game.initiator, game.acceptor));
        if (uint8(hashed[0]) & 1 == 0) {
            game.currentPlayer = Player.X;
        } else {
            game.currentPlayer = Player.O;
        }

        game.state = State.InProgress;  // Set the game state to in progress
        playerGames[msg.sender].push(gameId);  // Track the game for the acceptor
        emit GameAccepted(gameId, msg.sender);  // Emit event for game acceptance
    }

    // Function for players to make a move
    function makeMove(uint256 gameId, uint8 position) external {
        Game storage game = games[gameId];  // Get the game by ID
        require(game.state == State.InProgress, "Game is not in progress");  // Ensure the game is in progress
        require(msg.sender == game.initiator || msg.sender == game.acceptor, "Not a player of this game");  // Ensure the caller is a player of the game
        require(game.board[position] == Player.None, "Position already taken");  // Ensure the position is not already taken

        // Ensure it's the caller's turn
        if ((game.currentPlayer == Player.X && msg.sender == game.initiator) || (game.currentPlayer == Player.O && msg.sender == game.acceptor)) {
            game.board[position] = game.currentPlayer;  // Update the board with the player's move
            emit MoveMade(gameId, msg.sender, position);  // Emit event for the move

            // Check if the current player has won
            if (checkWin(game.board, game.currentPlayer)) {
                game.state = State.Completed;  // Set the game state to completed
                game.winner = msg.sender;  // Set the winner
                emit GameCompleted(gameId, msg.sender);  // Emit event for game completion
            } 
            // Check if the board is full (draw)
            else if (isBoardFull(game.board)) {
                game.state = State.Completed;  // Set the game state to completed
                game.winner = address(0);  // Set the winner to address(0) for a draw
                emit GameCompleted(gameId, address(0));  // Emit event for game completion
            } 
            // Switch to the next player
            else {
                game.currentPlayer = game.currentPlayer == Player.X ? Player.O : Player.X;
            }
        } else {
            revert("Not your turn");  // Revert if it's not the caller's turn
        }
    }

    // Internal function to check if a player has won
    function checkWin(Player[9] memory board, Player player) internal pure returns (bool) {
        uint8[3][8] memory winningCombos = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],  // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8],  // Columns
            [0, 4, 8], [2, 4, 6]             // Diagonals
        ];

        for (uint8 i = 0; i < 8; i++) {
            if (board[winningCombos[i][0]] == player && board[winningCombos[i][1]] == player && board[winningCombos[i][2]] == player) {
                return true;  // Return true if the player has a winning combination
            }
        }
        return false;  // Return false if no winning combination is found
    }

    // Internal function to check if the board is full (for a draw)
    function isBoardFull(Player[9] memory board) internal pure returns (bool) {
        for (uint8 i = 0; i < 9; i++) {
            if (board[i] == Player.None) {
                return false;  // Return false if any position is empty
            }
        }
        return true;  // Return true if all positions are filled
    }
}
