# @version ^0.3.0
# @license: MIT

# file == contract

# var: type
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
    self.balanceOf[msg.sender] = totalSupply
    
@external
def transfer(_amount: uint256, _to: address):
    assert self.balanceOf[msg.sender] >= _amount, "insufficient balance"
    self.balanceOf[msg.sender] -= _amount
    self.balanceOf[_to] += _amount

@external
def approve(_spender: address, _amount: uint256):
    # assert self.balanceOf[_owner] >= _amount, "Insufficient balance"
    self.allowances[msg.sender][_spender] = _amount

@external
def transferFrom(_owner: address, _to: address, _amount: uint256):
    assert self.allowances[_owner][_to] >= _amount, "insufficient allowance"
    assert self.balanceOf[_owner] >= _amount, "insufficient balance"
    self.allowances[_owner][msg.sender] -= _amount
    self.balanceOf[_owner] -= _amount
    self.balanceOf[_to] += _amount
    


    
    
