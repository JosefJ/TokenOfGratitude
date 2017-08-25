pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import "./PriceChecker.sol";

contract TokenOfGratitude is StandardToken, PriceChecker {
    using SafeMath for uint256;

    string constant public name = "Token Of Gratitude";
    string constant public symbol = "ToG";
    uint8 constant public decimals = 0;
    uint256 public totalSupply = 500;
    uint256 tokensLeft = 500;

    bool public fundraising = true;
    uint256 public donated;

    address public owner;

    /*
     * Medicines sans frontiers (MSF) | Doctors without borders - the public donation address
     * @dev TODO: reconsider changing timestamp to blocknumber estimate
     * @user please check for due diligence: TODO: LINK
     */
    address constant public addressOfMSF = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;

    // Timings
    uint256 public issuanceDate;
    uint256 public expirationDate;

    // Mappings for easier backchecking
    mapping (address => uint) redeemed;

    /**
     * constructor setting up the owner and the exact expiration time
     * @dev TODO: reconsider changing timestamp to blocknumber estimate
     */
    function TokenOfGratitude(){
        owner = msg.sender;
        issuanceDate = now;
        expirationDate = now + 5 years;
    }

    /**
     * the supporter fallback function
     * @dev TODO: describe
     */
    function() payable {
        require(fundraising);

        if (tokensLeft > 0) {
            uint256 toGet = howMany(msg.value);

            if (toGet > 0) {
                balances[msg.sender] += toGet;
                tokensGranted(toGet);
            }
        }
    }

    /**
     * Recursive function that counts amount of tokens to assign if a contribution overflows certain price range
     * @dev Recalculating tokens to receive based on teh currentPrice(2) function.
     * @dev Number of recursive entrances is equal to the number of price levels (not counting the initial call)
     * @return toGet - amount of tokens to receive from the particular price range
     */
    function howMany(uint256 _value) internal returns (uint256){

        var (price, canGet) =  currentPrice();
        uint256 toGet = _value.div(price);

        if (canGet == 0) {
            toGet = 0;
        } else if (toGet > canGet) {
            tokensLeft -= canGet;
            toGet = canGet + howMany(_value - (canGet*price));
        } else {
            tokensLeft -= toGet;
        }
        return toGet;
    }

    /**
     * Function returning the current price of ToG and amount of tokens available at that price
     * @dev can be used prior to the donation as a constant function but it is mainly used in the noname function
     * @return price - current price range
     * @return maxAtPrice - maximal amount of tokens available at current price
     */
    function currentPrice() constant returns (uint256 price, uint256 maxAtPrice){

        if (tokensLeft > 400) {
            return (100 finney, tokensLeft - 400);
        } else if (tokensLeft > 300) {
            return (200 finney, tokensLeft - 300);
        } else if (tokensLeft > 200) {
            return (500 finney, tokensLeft - 200);
        } else if (tokensLeft > 100) {
            return (750 finney, tokensLeft - 100);
        } else {
            return (1 ether, tokensLeft);
        }
    }

    /**
     * Function returning the current price of ToG
     * @dev can be used prior to the donation as a constant function but it is mainly used in the noname function
     * @param message should contain an encrypted contract info of the redeemer to setup a meeting
     */
    function redeem(string message) {
        require (balances[msg.sender] >= 1);
        require (now <= expirationDate);

        balances[msg.sender] -= 1;
        redeemed[msg.sender] += 1;

        // TODO: add UI for encrypted message field on the website
        tokenRedemption(msg.sender, message);
    }

    /**
     * Funds withdrawal and fundraiser finalization function
     * @dev requires to load the ETHUSD rate using getRateUSD() function otherwise throws
     */
    function withdrawFunds() {
        // Owner check replacing more expensive modifier
        require(owner == msg.sender);

        // Check the rate was queried less then 1 hour ago.
        // This check also proves that the rate was queried at all.
        require((now - rateAge) <= 3600);

        // Calling checkResult from PriceChecker contract
        uint256 funding = checkResult();
        uint256 raisedWei;

        if (funding <= 25000) {
            raisedWei = this.balance;
            owner.transfer(raisedWei);
            fundsToCommunity(raisedWei);
        } else {
            raisedWei = this.balance;
            uint256 charityShare = toPercentage(funding, funding-25000);
            uint256 toCharity = fromPercentage(raisedWei, charityShare);
            // Donate to charity first
            addressOfMSF.transfer(toCharity);
            fundsToMSF(toCharity);
            // Send funds to community;
            owner.transfer(raisedWei - toCharity);
            fundsToCommunity(raisedWei - toCharity);
        }

        // close the fundraiser (any donation after this will throw)
        fundraising = false;
        finishFundraiser(funding);

    }

    event fundsToMSF(uint value);
    event fundsToCommunity(uint value);
    event tokensGranted(uint tokens);
    event finishFundraiser(uint raised);
    event tokenRedemption(address supporter, string message);
}
