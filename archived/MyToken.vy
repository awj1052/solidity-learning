# @version ^0.3.0
# @license: MIT

# file == contract

event Transfer:
    owner: indexed(address)
    to: indexed(address)
    amount: uint256

event Approval:
    spender: indexed(address)
    amount: uint256

# var: type
owner: address
manager: address
name: public(String[64])
symbol: public(String[32])
decimals: public(uint256)
totalSupply: public(uint256)

balanceOf: public(HashMap[address, uint256])
allowances: public(HashMap[address, HashMap[address, uint256]])

@external
def __init__(name: String[64], symbol: String[32], decimals: uint256, totalSupply: uint256):
    self.name = name
    self.symbol = symbol
    self.decimals = decimals
    self.totalSupply = totalSupply * 10 ** decimals
    self.balanceOf[msg.sender] = totalSupply * 10 ** decimals
    self.owner = msg.sender
    self.manager = msg.sender

@internal
def onlyOwner(_sender: address):
    assert self.owner == _sender, "You are not authorized"

@internal
def onlyManager(_sender: address):
    assert self.manager == _sender, "You are not authorized to manage this contract"
    
@external
def transfer(_amount: uint256, _to: address):
    assert self.balanceOf[msg.sender] >= _amount, "insufficient balance"
    self.balanceOf[msg.sender] -= _amount
    self.balanceOf[_to] += _amount

    log Transfer(msg.sender, _to, _amount) # solidity: emit

@external
def approve(_spender: address, _amount: uint256):
    # assert self.balanceOf[_owner] >= _amount, "Insufficient balance"
    self.allowances[msg.sender][_spender] = _amount

    log Approval(_spender, _amount)

@external
def transferFrom(_owner: address, _to: address, _amount: uint256):
    assert self.allowances[_owner][_to] >= _amount, "insufficient allowance"
    assert self.balanceOf[_owner] >= _amount, "insufficient balance"
    self.allowances[_owner][msg.sender] -= _amount
    self.balanceOf[_owner] -= _amount
    self.balanceOf[_to] += _amount

    log Transfer(_owner, _to, _amount)
    
@internal
def _mint(_amount: uint256, _to: address):
    self.totalSupply += _amount
    self.balanceOf[_to] += _amount

    log Transfer(ZERO_ADDRESS, _to, _amount)

@external
def mint(_amount: uint256, _to: address):
    self.onlyManager(msg.sender)
    self._mint(_amount, _to)

@external
def setManager(_manager: address):
    self.onlyOwner(msg.sender)
    self.manager = _manager
