// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyToken {
    // 3개까지만 indexed 가능함. DB에서 COL에 INDEX KEY 거는 느낌인듯
    // recipet topics에 Encode된 Event가 들어감. indexed인 param도 같이 들어감. -> topics.length == 3
    // search를 할 때는 topics에서 찾음
    event Transfer(address indexed from, address indexed to, uint256 value);

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf; // key: address, value: uint256

    // 변수는 storage에 저장됨. storage는 블록체인에 저장되는 데이터, memory는 임시로 저장되는 데이터
    // storage는 가스비가 비쌈, memory는 가스비가 적게 듦
    // 지역변수는 memory에 저장하는 것이 가장 효율적임
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _amount) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(_amount *10**uint256(decimals), msg.sender); // msg.sender는 발행하는 사람 // amount MT
    }

    function _mint(uint256 amount, address owner) internal {
        totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount); // 무 -> owner
    }

    function transfer(uint256 amount, address to) external {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    // function totalSupply() public view returns (uint256) {
    //     return totalSupply;
    // }
    // function balanceOf(address _owner) public view returns (uint256) {
    //     return balanceOf[_owner];
    // }
    // function name() public view returns (string memory) {
    //     return name;
    // }
}