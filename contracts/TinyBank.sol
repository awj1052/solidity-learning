// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ManagedAccess.sol";

interface IMyToken {
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(uint256 amount, address owner) external;
}

contract TinyBank is ManagedAccess {
    event Staked(address indexed from, uint256 amount);
    event Withdraw(uint256 amount, address indexed to);

    IMyToken public stakingToken;

    mapping(address => uint256) public lastClaimedBlock;
    // address[] public stakedUsers; // dynamic array는 gas가 비쌈

    uint256 defaultRewardPerBlock = 1 * 10**18;
    uint256 rewardPerBlock; // 1 token per block

    mapping(address => uint256) public staked; // solidity는 mapping의 key를 조회 못하지만 빠름
    uint256 public totalStaked;

    constructor(IMyToken _stakingToken) ManagedAccess(msg.sender, msg.sender) {
        stakingToken = _stakingToken;
        rewardPerBlock = defaultRewardPerBlock;
    }

    modifier updateReward(address to) {
        if (staked[to] > 0) {
            uint256 blocks = block.number - lastClaimedBlock[to];
            uint256 reward = rewardPerBlock * blocks * staked[to] / totalStaked;
            stakingToken.mint(reward, to);
        }
        lastClaimedBlock[to] = block.number;
        _; // caller's code
    }

    function setRewardPerBlock(uint256 _amount) external onlyManager {
        rewardPerBlock = _amount;
    }

    function currentReward(address to) external view returns (uint256) {
        if (staked[to] > 0) {
            uint256 blocks = block.number - lastClaimedBlock[to];
            return (blocks * rewardPerBlock * staked[to]) / totalStaked;
        } else {
            return 0;
        }
    }



    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount >= 0, "cannnot stake 0 amount");
        // 여기서 approve를 한다면??
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(staked[msg.sender] >= _amount, "insufficient staked token");
        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
            
        emit Withdraw(_amount, msg.sender);
    }
}
