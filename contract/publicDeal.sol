//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IDeal {
    function approve(string memory _gistId, string memory _gistHash) external;
}

contract PrivateDeal is IDeal {
    
    address issuer;

    mapping(address => uint32) public participants;
    mapping(address => bool) public approvedByParticipants;

    uint256 public dealPrice;
    uint256 public payed;

    bytes32 public gistId;
    bytes32 public gistHash;

    //modifier onlyParticipant() {
        //require(participants[msg.sender], "You are not participant");
        //_;
    //}
    modifier onlyParticipant() {
        require(
            approvedByParticipants[msg.sender],"You are not participant");
        _;
    }


    constructor(address[] memory _participants, uint256 _price, string memory _gistId, string memory _gistHash) {
    
        issuer = msg.sender;
        dealPrice = _price;
        gistId = keccak256(abi.encodePacked(_gistId));
        gistHash = keccak256(abi.encodePacked(_gistHash));
        
    
    for (uint256 i = 0; i < _participants.length; i++) {
            address participant = _participants[i];

            approvedByParticipants[participant] = false;
    }

    }

    function approve(string memory _gistId, string memory _gistHash) external override onlyParticipant {
        //require(gistId == _gistId, "GistId is not equals");
        //require(gistHash == _gistHash, "GistHash is not equals");
        require(
            gistId == keccak256(abi.encodePacked(_gistId)),
            "GistId is not equals"
        );
        require(gistHash == keccak256(abi.encodePacked(_gistHash)),"GistHash is not equals");
        require(approvedByParticipants[msg.sender] != true, "Deal has been approved");
        require(payed == dealPrice, "Deal hasn`t been paid");

        payable(issuer).transfer(payed);
        approvedByParticipants[msg.sender] = true;

    }

    receive() external payable onlyParticipant {
        require(dealPrice == msg.value, "You should pay exact value of deal");

        payed = msg.value;
    }

    
}