pragma solidity ^0.4.6;

import "./StandardToken.sol";

contract MostInvestFund is StandardToken {

    address public emissionContractAddress = 0x0;

    string constant public name = "MostInvest Fund";
    string constant public symbol = "MIF";
    uint8 constant public decimals = 8;

    address public owner = 0x0;
    bool public emissionEnabled = true;
    bool transfersEnabled = true;

    modifier isCrowdfundingContract() {
        // Only emission address is allowed to proceed.
        if (msg.sender != emissionContractAddress) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        // Only owner is allowed to do this action.
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    /*
     * Contract functions
     */

    function issueTokens(address _for, uint tokenCount)
        external
        isCrowdfundingContract
        returns (bool)
    {
        if (emissionEnabled == false) {
            throw;
        }

        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        return true;
    }

    function withdrawTokens(uint tokenCount)
        public
        returns (bool)
    {
        uint balance = balances[msg.sender];
        if (balance < tokenCount) {
            return false;
        }
        balances[msg.sender] -= tokenCount;
        totalSupply -= tokenCount;
        return true;
    }

    function changeEmissionContractAddress(address newAddress)
        external
        onlyOwner
        returns (bool)
    {
        emissionContractAddress = newAddress;
    }

    function enableTransfers(bool value)
        external
        onlyOwner
    {
        transfersEnabled = value;
    }

    function enableEmission(bool value)
        external
        onlyOwner
    {
        emissionEnabled = value;
    }

    function transfer(address _to, uint256 _value)
        returns (bool success)
    {
        if (transfersEnabled == true) {
            return super.transfer(_to, _value);
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        returns (bool success)
    {
        if (transfersEnabled == true) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }


    function MostInvestFund(address _owner)
    {
        totalSupply = 0;
        owner = _owner;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
