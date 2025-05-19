//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract MultiManagedAccess {
    uint constant MANAGER_NUMBERS = 3;
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

    function isManager() internal view returns (uint256) {
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) {
            if (msg.sender == managers[i]) return i;
        }
        revert("You are not a manager");
    }

    function reset() internal {
        for(uint256 i = 0; i < MANAGER_NUMBERS; i++) confirmed[i] = false;
    }

    modifier onlyAllConfirmed() {
        isManager();
        require(allConfirmed(), "Not all confirmed yet");
        reset();
        _;
    }

    function confirm() external {
        uint256 index = isManager();
        confirmed[index] = true;
    }
}
