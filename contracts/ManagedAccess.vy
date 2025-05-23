# @version ^0.3.0
# @license: MIT

owner: address
manager: address

@external
def __init__(_owner: address, _manager: address):
    self.owner = _owner
    self.manager = _manager

@internal
def onlyOwner(_sender: address):
    assert _sender == self.owner, "You are not authorized"

@internal
def onlyManager(_sender: address):
    assert _sender == self.manager, "You are not authorized to manage this contract"
