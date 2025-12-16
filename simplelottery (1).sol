// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleLottery {
    address public owner;
    address[] public players;
    uint256 public ticketPrice;
    address public lastWinner;
    uint256 public endTime; 


    event TicketBought(address indexed player);
    event WinnerPicked(address indexed winner, uint256 amountWon);

    constructor(uint256 _ticketPrice, uint256 _duration) {
    require(_ticketPrice > 0, "Ticket price must be greater than zero");
    owner = msg.sender;
    ticketPrice = _ticketPrice;
    endTime = block.timestamp + _duration; // Set end time

    }
    // Anyone can buy a ticket
    function buyTicket() external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");

        players.push(msg.sender);
        emit TicketBought(msg.sender);
    }

    // Admin picks a winner
    function pickWinner() external {
        require(msg.sender == owner, "Only owner can pick winner");
        require(block.timestamp >= endTime, "Lottery not ended yet");
        require(players.length > 1, "No players in lottery or only 1 player");

        // Simple random generator (not secure, but OK for demo projects)
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, players, block.prevrandao))
        );

        uint256 winnerIndex = randomNumber % players.length;
        address payable winner = payable(players[winnerIndex]);

        uint256 amountWon = address(this).balance;

        // Send entire pool to the winner
        winner.transfer(amountWon);
        lastWinner = winner;

        emit WinnerPicked(winner, amountWon);

        // Reset for next round
        delete players;
    }

    // VIEW FUNCTIONS
    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


}
