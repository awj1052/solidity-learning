// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(uint256 amount, address owner) external;
}

contract TinyBank {
    event Staked(address indexed from, uint256 amount);
    event Withdraw(uint256 amount, address indexed to);

    IMyToken public stakingToken;

    mapping(address => uint256) public lastClaimedBlock;
    // address[] public stakedUsers; // dynamic array는 gas가 비쌈

    uint256 rewardPerBlock = 1 * 10**18; // 1 token per block

    mapping(address => uint256) public staked; // solidity는 mapping의 key를 조회 못하지만 빠름
    uint256 public totalStaked;

    constructor(IMyToken _stakingToken) {
        stakingToken = _stakingToken;
    }

    function updateReward(address to) internal {
        uint256 blocks = block.number - lastClaimedBlock[to];
        uint256 reward = rewardPerBlock * blocks * staked[to] / totalStaked;
        stakingToken.mint(reward, to);
        lastClaimedBlock[to] = block.number;
    }

    function stake(uint256 _amount) external {
        require(_amount >= 0, "cannnot stake 0 amount");
        updateReward(msg.sender);
        // 여기서 approve를 한다면??
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(staked[msg.sender] >= _amount, "insufficient staked token");
        updateReward(msg.sender);
        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
            
        emit Withdraw(_amount, msg.sender);
    }
}
