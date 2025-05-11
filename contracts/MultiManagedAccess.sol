//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract MultiManagedAccess {
    uint constant MANAGER_NUMBERS = 5;
    address public owner;
    address[MANAGER_NUMBERS] public managers;
    bool[MANAGER_NUMBERS] public confirmed;
    // manager[i] --> confirmed[i]

    constructor(address _owner, address[MANAGER_NUMBERS] memory _managers) {
        owner = _owner;
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) {
            managers[i] = _managers[i];
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized");
        _;
    }

    function allConfirmed() internal view returns (bool){
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) {
            if (!confirmed[i]) return false;
        }
        return true;
    }

    function reset() internal {
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) confirmed[i] = false;
    }

    modifier onlyAllConfirmed() {
        require(allConfirmed(), "Not all managers confirmed yet");
        reset();
        _;
    }

    function confirm() external {
        bool found = false;
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) {
            if (msg.sender == managers[i]) {
                found = true;
                confirmed[i] = true;
                break;
            }
        }
        require(found, "You are not one of managers");
    }
}
