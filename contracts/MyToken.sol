// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ManagedAccess.sol";

contract MyToken is ManagedAccess {
    // 3개까지만 indexed 가능함. DB에서 COL에 INDEX KEY 거는 느낌인듯
    // recipet topics에 Encode된 Event가 들어감. indexed인 param도 같이 들어감. -> topics.length == 3
    // search를 할 때는 topics에서 찾음
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed spender, uint256 amount);

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf; // key: address, value: uint256
    mapping(address => mapping(address => uint256)) public allowance;

    // 변수는 storage에 저장됨. storage는 블록체인에 저장되는 데이터, memory는 임시로 저장되는 데이터
    // storage는 가스비가 비쌈, memory는 가스비가 적게 듦
    // 지역변수는 memory에 저장하는 것이 가장 효율적임
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _amount) ManagedAccess(msg.sender, msg.sender) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(_amount *10**uint256(decimals), msg.sender); // msg.sender는 발행하는 사람 // amount MT
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount; // owner -> spender -> amount amount만큼 보내도 되게 허용
        emit Approval(spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external {
        address spender = msg.sender;
        require(allowance[from][spender] >= amount, "insufficient allowance");
        allowance[from][spender] -= amount;
        // balanceOf 는 require 안하나? // 드디어 해결
        require(balanceOf[from] >= amount, "insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function mint(uint256 amount, address to) external onlyManager {
        _mint(amount, to);
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager; // contract manager
    }
    
    function _mint(uint256 amount, address to) internal {
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount); // 무 -> to
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

/*
approve
 - allow spender address to send my token 내 토큰을 다른 사람이 보낼 수 있게
 신뢰할 수 있는 사람, 주소에 위임해야함.
transferFrom
 - spender: owner -> target address
 권한을 위임 받은 사람이 내 토큰을 다른 사람에게 보내는 것

* token owner --> bank contract
* token owner --> router contract --> bank contract 일반적인 패턴, router contract에게 권한을 줌
* token owner --> router contract --> bank contract(multi contract)
*/