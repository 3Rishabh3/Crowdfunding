// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Crowdfunding {
    mapping(address => bool) contributors;
    uint256 public cont;
    address public manager;
    uint256 public extra;
    struct Request {
        string category;
        string description;
        address payable recipient;
        uint256 deadline;
        uint256 target;
        uint256 raisedAmount;
        bool completed;
        uint256 noOfDonors;
        mapping(address => uint256) donors;
    }
    mapping(uint256 => Request) public requests;
    uint256 public numRequests;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {}

    function sendEth(uint256 i) public payable {
        require(block.timestamp < requests[i].deadline, "deadline passed");
        require(
            requests[i].raisedAmount < requests[i].target,
            "target Achieved"
        );
        if (requests[i].donors[msg.sender] == 0) {
            requests[i].noOfDonors++;
            if (contributors[msg.sender] == false) {
                contributors[msg.sender] = true;
                cont++;
            }
        }
        requests[i].donors[msg.sender] += msg.value;
        requests[i].raisedAmount += msg.value;

        if (requests[i].raisedAmount > requests[i].target) {
            extra += (requests[i].raisedAmount - requests[i].target);
        }
    }

    modifier onlyManger() {
        require(msg.sender == manager, "Only manager can calll this function");
        _;
    }

    function getContractBalance() public view onlyManger returns (uint256) {
        return address(this).balance;
    }

    function createRequests(
        string memory cate,
        string memory _description,
        address payable _recipient,
        uint256 _time,
        uint256 _target
    ) public onlyManger {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.category = cate;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.deadline = block.timestamp + _time;
        newRequest.target = _target;
        newRequest.raisedAmount = 0;
        newRequest.completed = false;
        newRequest.noOfDonors = 0;
    }

    function makePayment(uint256 i) public payable onlyManger {
        require(
            requests[i].raisedAmount >= requests[i].target,
            "Target not Acheived Yet"
        );
        Request storage thisRequest = requests[i];
        require(
            thisRequest.completed == false,
            "The request has been completed"
        );
        thisRequest.recipient.transfer(thisRequest.target);
        thisRequest.completed = true;
    }
}
