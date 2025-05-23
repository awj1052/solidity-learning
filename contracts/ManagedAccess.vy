# @version ^0.4.1
# @license: MIT

owner: address
manager: address

@deploy
def __init__(_stakingToken: address):
    self.owner = msg.sender
    self.manager = msg.sender

@internal
def onlyOwner(_owner: address):
    assert msg.sender == _owner, "You are not authorized"  

@internal
def onlyManager(_manager: address):
    assert msg.sender == _manager, "You are not authorized to manage this contract"   