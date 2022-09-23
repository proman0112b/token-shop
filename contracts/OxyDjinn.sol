//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
    string public name = "OxyDjinn";
    string public symbol = "COO";
    uint256 public decimals = 18;
    uint256 public totalSupply = 300000000 * (10**decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256))  public allowance;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
        );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor()
    {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)
    public
    returns (bool success)
    {
        // Require that sender has enough tokens to spend.
        require(balanceOf[msg.sender] >= _value);

        _transfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        // Require the address is not invalid.
        require(_to != address(0));

        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;

        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value)
    public
    returns (bool success)
    {
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool success)
    {
        require(_value <= balanceOf[_from], 'insufficient balance');
        require(_value <= allowance[_from][msg.sender], 'insufficient allowance');

        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;

        _transfer(_from, _to, _value);

        return true;
    }
}
