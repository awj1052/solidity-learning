// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract NativeBank {
    mapping(address => uint256) public balanceOf;
    constructor() {
    }

    function withdraw() external {
        uint256 balance = balanceOf[msg.sender];
        require(balance > 0, "insufficient balance");

        // 0으로 만들기 전에 call때문에 재진입 공격이 발생할 수 있다. re-entrancy 공격
        (bool success,) = msg.sender.call{value: balance}(""); // msg.sender의 receive, fallback을 호출
        require(success, "failed to send native token");

        balanceOf[msg.sender] = 0;
    }

    receive() external payable { // fallback으로 대체 가능
        balanceOf[msg.sender] += msg.value;
    }
}
