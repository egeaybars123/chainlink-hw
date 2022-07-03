// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Homework.sol";

contract MainHomework is Ownable {

    //registering homework, done by the contract owner
    //only creates homework instances and validates from this mapping.
    struct HomeworkData {
        bool given;
        uint256 id;
    }

    mapping (address => HomeworkData) givenHomework;

    struct HomeworkInstanceData{
        address player;
        Homework homework;
        bool completed;
    }

    //storing who participated in the platform
    //prevents malicious contracts from claiming the achievement NFT by providing fake validations.
    mapping (address => HomeworkInstanceData) homeworkInstances; 
    
    function addHomework(Homework _homework, uint256 _id) public onlyOwner {
        givenHomework[address(_homework)] = HomeworkData(true,_id);
    }

    function createHomeworkInstance(Homework _homework) public payable {
        require(givenHomework[address(_homework)].given);

        address homework_instance = _homework.createInstance{value: msg.value}(msg.sender); 

        homeworkInstances[homework_instance] = HomeworkInstanceData(msg.sender, _homework, false);
    }

    function submitHomework(address payable _instance) public {
        HomeworkInstanceData storage instance = homeworkInstances[_instance];
        require(instance.player == msg.sender);
        require(instance.completed == false);

        if (instance.homework.validateInstance(_instance, msg.sender)) {
            instance.completed = true;
        }
    }


} 