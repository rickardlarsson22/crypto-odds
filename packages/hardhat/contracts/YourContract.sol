//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./ATM.sol";
import "./Console.sol";
import "./Ownable.sol";

contract YourContract is ATM, Ownable {
    event NewBet(address addy, uint amount, Team teamBet);

    struct Bet {
        string team;
        address addy;
        uint amount;
        Team teamBet;
    }

    struct Team {
        string team;
        uint totalBetAmount;
    }

    Bet[] public bets;
    Team[] public teams;

    address payable conOwner;
    uint public totalBetMoney = 0;

    mapping(address => uint) public numBetsAddress;

    constructor() payable {
        conOwner = payable(msg.sender);
        teams.push(Team("team1", 0));
        teams.push(Team("team2", 0));
    }

    function createTeam(string memory _team) public {
        teams.push(Team(_team, 0));
    }

    function getTotalBetAmount(uint _teamId) public view returns (uint) {
        return teams[_teamId].totalBetAmount;
    }

    function createBet(string memory _team, uint _teamId) external payable {
        require(msg.sender != conOwner, "Owner is unable to place the bet");
        require(
            numBetsAddress[msg.sender] == 0,
            "User has already placed a bet"
        );
        require(msg.value > 0.01 ether, "Bet must be higher than 0.01 ether");

        deposit();

        bets.push(Bet(_team, msg.sender, msg.value, teams[_teamId]));

        if (_teamId == 0) {
            teams[0].totalBetAmount += msg.value;
        }

        if (_teamId == 1) {
            teams[1].totalBetAmount += msg.value;
        }

        numBetsAddress[msg.sender]++;

        (bool sent, bytes memory data) = conOwner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        totalBetMoney += msg.value;

        emit NewBet(msg.sender, msg.value, teams[_teamId]);
    }

    function teamWinDistribution(uint _teamId) public payable onlyOwner {
        deposit();
        uint div;

        if (_teamId == 0) {
            for (uint i = 0; i < bets.length; i++) {
                if (
                    keccak256(abi.encodePacked((bets[i].teamBet.team))) ==
                    keccak256(abi.encodePacked("team1"))
                ) {
                    address payable receiver = payable(bets[i].addy);
                    console.log(receiver);
                    div =
                        (bets[i].amount *
                            (10000 +
                                ((getTotalBetAmount(1) * 10000) /
                                    getTotalBetAmount(0)))) /
                        10000;

                    (bool sent, bytes memory data) = receiver.call{value: div}(
                        ""
                    );
                    require(sent, "Failed to send Ether");
                }
            }
        } else {
            for (uint i = 0; i < bets.length; i++) {
                if (
                    keccak256(abi.encodePacked((bets[i].teamBet.team))) ==
                    keccak256(abi.encodePacked("team2"))
                ) {
                    address payable receiver = payable(bets[i].addy);
                    div =
                        (bets[i].amount *
                            (10000 +
                                ((getTotalBetAmount(0) * 10000) /
                                    getTotalBetAmount(1)))) /
                        10000;
                    console.log(getTotalBetAmount(0));
                    console.log(div);

                    (bool sent, bytes memory data) = receiver.call{value: div}(
                        ""
                    );
                    require(sent, "Failed to send Ether");
                }
            }
        }

        totalBetMoney = 0;
        teams[0].totalBetAmount = 0;
        teams[1].totalBetAmount = 0;

        for (uint i = 0; i < bets.length; i++) {
            numBetsAddress[bets[i].addy] = 0;
        }
    }
}
