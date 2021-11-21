// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message, string username);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        string username;
    }

    Wave[] waves;
  mapping(address => uint256) public lastWavedAt;
  mapping(string => address) public userNames;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message, string memory username) public returns(string memory){

           /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, "Must wait 30 seconds before waving again.");

           /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp,username));

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        userNames[username] = msg.sender;
        emit NewWave(msg.sender, block.timestamp, _message,username);

        return username;
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }

    function validateUserName(string memory username) public view returns (bool) {
         bool returnedValue = false;

        require(bytes(username).length > 0,'Username is required');
        if(address(userNames[username]) != address(0x0) && address(userNames[username]) != address(msg.sender)){
            returnedValue =  false;
        }
        if(userNames[username] == address(0x0)){
          returnedValue =  true;
        }
        if(userNames[username] == msg.sender){
            returnedValue =  true;
        }
        return returnedValue;
    }


}