# @version ^0.3.0
# @license: MIT

import ManagedAccess
initializes: ManagedAccess

INIT_REWARD: constant(uint256) = 1 * 10 ** 18

interface IMyToken:
    def transfer(_amount: uint256, _to: address): nonpayable
    def transferFrom(_owner: address, _to: address, _amount: uint256): nonpayable
    def mint(_amount: uint256, _to: address): nonpayable

event Staked:
    _owner: indexed(address)
    _amount: uint256

event Withdraw:
    _amount: uint256
    _to: indexed(address)

staked: public(HashMap[address, uint256])
totalStaked: public(uint256)

stakingToken: IMyToken

rewardPerBlock: uint256
lastClaimedBlock: HashMap[address, uint256]

@external
def __init__(_stakingToken: IMyToken):
    ManagedAccess.__init__(msg.sender, msg.sender)
    self.stakingToken = _stakingToken
    self.rewardPerBlock = INIT_REWARD

@external
def setRewardPerBlock(_rewardPerBlock: uint256):
    ManagedAccess.onlyManager(msg.sender)
    self.rewardPerBlock = _rewardPerBlock

@internal
def updateReward(_to: address):
    if self.staked[_to] > 0:
        blocks: uint256 = block.number - self.lastClaimedBlock[_to]
        reward: uint256 = self.rewardPerBlock * blocks * self.staked[_to] / self.totalStaked
        self.stakingToken.mint(reward, _to)
    self.lastClaimedBlock[_to] = block.number

@external
def stake(_amount: uint256):
    assert _amount > 0, "cannot stake 0 amount"
    self.updateReward(msg.sender)
    self.stakingToken.transferFrom(msg.sender, self, _amount) # solidity: address(this)
    self.staked[msg.sender] += _amount
    self.totalStaked += _amount
    log Staked(msg.sender, _amount)

@external
def withdraw(_amount: uint256):
    assert self.staked[msg.sender] >= _amount, "insufficient staked token"
    self.updateReward(msg.sender)
    self.stakingToken.transfer(_amount, msg.sender)
    self.staked[msg.sender] -= _amount
    self.totalStaked -= _amount
    log Withdraw(_amount, msg.sender)
