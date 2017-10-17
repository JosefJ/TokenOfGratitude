pragma solidity ^0.4.11;

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol';
import "github.com/JosefJ/TokenOfGratitude/testnet/DataFeeds.sol";

contract TokenOfGratitude is StandardToken, usingDataFeeds {
    using SafeMath for uint256;

    // Standard token variables
    string constant public name = "Token Of Gratitude";
    string constant public symbol = "ToG";
    uint8 constant public decimals = 0;
    uint256 public totalSupply = 500;

    // Utility variables
    uint256 public tokensLeft = 500;
    address public owner;
    bool public fundraising = true;
    bool public haveRandom;
    uint256 public rate;

    /*
     * Randomly chosen number for the meal invitation winner
     * @dev each supporter gets a nonce - the luckyNumber is randomly picked nonce by Oraclize
     * @dev then points to donorsList[luckyNumber] mapping to get the address of the winner
     */
    uint256 luckyNumber;
    address goldenTicketOwner;

    /*
     * Medicines sans frontiers (MSF) | Doctors without borders - the public donation address
     * @dev please check for due diligence:
     * @dev Link: https://www.lekari-bez-hranic.cz/bankovni-spojeni#kryptomeny
     */
    address constant public addressOfMSF = 0x249F02676D09A41938309447fdA33FB533d91DFC;

    // Timestamp variable used in constructor
    uint256 public fundraiserEnd;
    uint256 public expirationDate;

    // Mapping of supporters for random selection
    uint256 public donors = 0;
    mapping (address => bool) donated;
    mapping (uint256 => address) donorsList;

    // Mappings for easier backchecking
    mapping (address => uint) redeemed;

    /**
     * constructor setting up the owner and the exact expiration time
     */
    function TokenOfGratitude(){
        owner = msg.sender;
        fundraiserEnd = now + 5 minutes;
        expirationDate = now + 10 minutes;
    }

    /**
     * The donation fallback function
     * @dev Implementation of the fallback function for incoming ETH
     * @dev Steps described bellow
     */
    function() payable {

        // Check if the fundraising is still running
        require(now <= fundraiserEnd);

        // Sign up first-time donors to the list + give them a nonce so they can win the golden ticket!
        if (!donated[msg.sender]) {
            donated[msg.sender] = true;
            donorsList[donors] = msg.sender;
            donors += 1;
        }

        // Check if there are still tokens left (otherwise skipped)
        if (tokensLeft > 0) {

            // See how many tokens can the donor get.
            uint256 toGet = howMany(msg.value);

            // If some, give the tokens to the donor.
            if (toGet > 0) {
                balances[msg.sender] += toGet;
                tokensGranted(msg.sender, toGet);
            }
        }
    }

    /**
     * Recursive function that counts amount of tokens to assign (even if a contribution overflows certain price range)
     * @dev Recalculating tokens to receive based on teh currentPrice(2) function.
     * @dev Number of recursive entrances is equal to the number of price levels (not counting the initial call)
     * @return toGet - amount of tokens to receive from the particular price range
     */
    function howMany(uint256 _value) internal returns (uint256){

        // Check current price level
        var (price, canGet) =  currentPrice();
        uint256 toGet = _value.div(price);

        // Act based on amount of tokens to get
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
            return (10 finney, tokensLeft - 400);
        } else if (tokensLeft > 300) {
            return (20 finney, tokensLeft - 300);
        } else if (tokensLeft > 200) {
            return (30 finney, tokensLeft - 200);
        } else if (tokensLeft > 100) {
            return (40 finney, tokensLeft - 100);
        } else {
            return (50 finney, tokensLeft);
        }
    }

    /**
     * Function returning the current price of ToG
     * @dev can be used prior to the donation as a constant function but it is mainly used in the noname function
     * @param message should contain an encrypted contract info of the redeemer to setup a meeting
     */
    function redeem(string message) {

        // Check caller has a token
        require (balances[msg.sender] >= 1);

        // Check tokens did not expire
        require (now <= expirationDate);

        // Lock the token against further transfers
        balances[msg.sender] -= 1;
        redeemed[msg.sender] += 1;

        // Call out
        tokenRedemption(msg.sender, message);
    }

    /**
     * Function using the Golden ticket - the current holder will be able to get the prize only based on the "goldenTicketUsed" event
     * @dev First checks the GT owner, then fires the event and then changes the owner to null so GT can't be used again
     * @param message should contain an encrypted contract info of the redeemer to claim the reward
     */
    function useGoldenTicket(string message){
        require(msg.sender == goldenTicketOwner);
        goldenTicketUsed(msg.sender, message);
        goldenTicketOwner = 0x0;
    }

    /**
     * Function using the Golden ticket - the current holder will be able to get the prize only based on the "goldenTicketUsed" event
     * @dev First checks the GT owner, then change the owner and fire an event about the ticket changing owner
     * @dev The Golden ticket isn't a standard ERC20 token and therefore it needs special handling
     * @param newOwner should be a valid address of the new owner
     */
    function giveGoldenTicket(address newOwner) {
        require (msg.sender == goldenTicketOwner);
        goldenTicketOwner = newOwner;
        goldenTicketMoved(newOwner);
    }

    /**
     * Funds withdrawal and fundraiser finalization function
     * @dev requires to load the ETHUSD rate using getRateUSD() function otherwise throws
     */

    function prepareFinalization() {
        // Owner check
        require(msg.sender == owner);

        // Check the fundraiser period is over
        require(now >= fundraiserEnd);

        // Make two Oraclize queries for ETHUSD rate and a random number
        getRateUSD();
        getRandom();

        // Helper boolen for the "finalizeFundraiser()" function
        fundraising = false;
    }

    function finalizeFundraiser() {

        // Owner check replacing more expensive modifier
        require(msg.sender == owner);

        // Check the "prepareFinalization" function was called
        require(!fundraising);

        // Check the rate was queried less then 1 hour ago
        // This check also proves that the rate was queried at all
        require((now - rateAge) <= 3600);

        // Check the random number was received
        require(haveRandom);

        // Calling checkResult from PriceChecker contract
        uint256 funding = checkResult();
        uint256 raisedWei = this.balance;
        uint256 charityShare;
        uint256 toCharity;

        // If goal isn't met => send everything to MSF
        if (funding < 10000) {
            addressOfMSF.transfer(raisedWei);
            fundsToMSF(toCharity);
        } else if (funding < 25000) {

            // If 2nd goal isn't met => send the rest above the 1st goal to MSF
            charityShare = toPercentage(funding, funding-10000);
            toCharity = fromPercentage(raisedWei, charityShare);

            // Donate to charity first
            addressOfMSF.transfer(toCharity);
            fundsToMSF(toCharity);

            // Send funds to community;
            owner.transfer(raisedWei - toCharity);
            fundsToCommunity(raisedWei - toCharity);
        } else {

            // If 2nd goal is met => send the rest above the 2nd goal to MSF
            charityShare = toPercentage(funding, funding-25000);
            toCharity = fromPercentage(raisedWei, charityShare);

            // Donate to charity first
            addressOfMSF.transfer(toCharity);
            fundsToMSF(toCharity);

            // Send funds to community;
            owner.transfer(raisedWei - toCharity);
            fundsToCommunity(raisedWei - toCharity);
        }

        // close the fundraiser
        finishFundraiser(funding);
    }

    /**
     * @dev Checking results of the fundraiser in USD
     * @return rated - total funds raised converted to USD
     */
    function checkResult() internal returns (uint256){
        uint256 raised = this.balance;
        // convert wei => usd to perform checks
        uint256 rated = (raised.mul(rate)).div(10000000000000000000000);
        return rated;
    }

    /**
     * Helper function to get split funds between the community and charity I
     * @dev Counts percentage of the total funds that belongs to the charity
     * @param total funds raised in USD
     * @param part of the total funds raised that should go to the charity
     * @return percentage in full expressed as a natural number between 0 and 100
     */
    function toPercentage (uint256 total, uint256 part) internal returns (uint256) {
        return (part*100)/total;
    }

    /**
     * Helper function to get split funds between the community and charity II
     * @dev Counts the exact amount of Wei to get send to the charity
     * @param value of total funds raised in Wei
     * @param percentage to be used obtained from the toPercentage(2) function
     * @return amount of Wei to be send to the charity
     */
    function fromPercentage(uint256 value, uint256 percentage) internal returns (uint256) {
        return (value*percentage)/100;
    }

    // ToG handing-over event
    event tokensGranted(address indexed donor, uint tokens);

    // Fundraising finalization events
    event finishFundraiser(uint raised);
    event fundsToMSF(uint value);
    event fundsToCommunity(uint value);

    // ToG redeem event with encrypted message (hopefully a contact info)
    event tokenRedemption(address indexed supported, string message);

    // Special events for a very special golden ticket!
    event goldenTicketFound(address winner);
    event goldenTicketMoved(address indexed newOwner);
    event goldenTicketUsed(address charlie, string message);
}
