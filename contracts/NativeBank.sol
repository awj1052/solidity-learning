// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract NativeBank {
    mapping(address => uint256) public balanceOf;
    constructor() {
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}
