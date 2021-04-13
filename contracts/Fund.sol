pragma solidity ^0.4.6;

import "./MostInvestFund.sol";
import "./owned.sol";

contract Fund is owned {

	/*
     * External contracts
     */
    MostInvestFund public mostInvestFund;

	/*
     * Storage
     */
    address public ethAddress;
    address public multisig;
    address public supportAddress;
    uint public tokenPrice = 1 finney; // 0.001 ETH

    mapping (address => address) public referrals;

    /*
     * Contract functions
     */

	/// @dev Withdraws tokens for msg.sender.
    /// @param tokenCount Number of tokens to withdraw.
    function withdrawTokens(uint tokenCount)
        public
        returns (bool)
    {
        return mostInvestFund.withdrawTokens(tokenCount);
    }

    function issueTokens(address _for, uint tokenCount)
    	private
    	returns (bool)
    {
    	if (tokenCount == 0) {
        return false;
      }

      if (!mostInvestFund.issueTokens(_for, tokenCount)) {
        // Tokens could not be issued.
        throw;
	    }

	    return true;
    }

    /// @dev Issues tokens for users who made investment.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param valueInWei investment in wei
    function addInvestment(address beneficiary, uint valueInWei)
        external
        onlyOwner
        returns (bool)
    {
        uint tokenCount = calculateTokens(valueInWei);
    	return issueTokens(beneficiary, tokenCount);
    }

    /// @dev Issues tokens for users who made direct ETH payment.
    function fund()
        public
        payable
        returns (bool)
    {
        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        address beneficiary = msg.sender;
        uint tokenCount = calculateTokens(msg.value);
        uint roundedInvestment = tokenCount * tokenPrice / 100000000;

        // Send change back to user.
        if (msg.value > roundedInvestment && !beneficiary.send(msg.value - roundedInvestment)) {
          throw;
        }
        // Send money to the fund ethereum address
        if (!ethAddress.send(roundedInvestment)) {
          throw;
        }
        return issueTokens(beneficiary, tokenCount);
    }

    function calculateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {
        return valueInWei * 100000000 / tokenPrice;
    }

    function estimateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {
        return valueInWei * 95000000 / tokenPrice;
    }

    function setTokenPrice(uint valueInWei)
        public
        onlyOwner
    {
        tokenPrice = valueInWei;
    }

    function getTokenPrice()
        public
        constant
        returns (uint)
    {
        return tokenPrice;
    }

    function changeMultisig(address newMultisig)
        onlyOwner
    {
        multisig = newMultisig;
    }

    function changeEthAddress(address newEthAddress)
        onlyOwner
    {
        ethAddress = newEthAddress;
    }

    /// @dev Contract constructor function
    /// @param _ethAddress Ethereum address of the mostInvestFund.
    /// @param _multisig Address of the owner of mostInvestFund.
    /// @param _supportAddress Address of the developers team.
    /// @param _tokenAddress Address of the token contract.
    function Fund(address _owner, address _ethAddress, address _multisig, address _supportAddress, address _tokenAddress)
    {
        owner = _owner;
        ethAddress = _ethAddress;
        multisig = _multisig;
        supportAddress = _supportAddress;
        mostInvestFund = mostInvestFund(_tokenAddress);
    }

    /// @dev Fallback function. Calls fund() function to create tokens.
    function () payable {
        fund();
    }
}
