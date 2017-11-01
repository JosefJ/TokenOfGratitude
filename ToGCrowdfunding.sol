pragma solidity ^0.4.11;

import "./TokenOfGratitude.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint256;

    // The token being sold
    TokenOfGratitude public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function Crowdsale(uint256 _startTime, uint256 _endTime) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_wallet != 0x0);

        token = createTokenContract();
        startTime = _startTime;
        endTime = _endTime;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract() internal returns (TokenOfGratitude) {
        return new TokenOfGratitude();
    }
    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {}


    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }


}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }
}

/**
 * @title Token of Gratitude fundraiser
 */
contract GratitudeCrowdsale is FinalizableCrowdsale, usingOraclize {

    // Utility variables
    uint256 public tokensLeft;
    uint256 public rate;
    uint public rateAge;
    address public owner;
    bool fundraising;

    // Defining helper variables to differentiate Oraclize queries
    bytes32 qID1;
    bytes32 qID2;

    /*
     * Randomly chosen number for the meal invitation winner
     * @dev each supporter gets a nonce - the luckyNumber is randomly picked nonce by Oraclize
     * @dev then points to donorsList[luckyNumber] mapping to get the address of the winner
     */
    bool public haveRandom;
    uint256 luckyNumber;

    /*
     * Medicines sans frontiers (MSF) | Doctors without borders - the public donation address
     * @dev please check for due diligence:
     * @notice Link to English site: https://www.lekari-bez-hranic.cz/en/bank-details#cryptocurrencies
     * @notice Link to Czech site: https://www.lekari-bez-hranic.cz/bankovni-spojeni#kryptomeny
     * @notice Link to Etherscan: https://etherscan.io/address/0x249f02676d09a41938309447fda33fb533d91dfc
     */
    address constant public addressOfMSF = 0x249F02676D09A41938309447fdA33FB533d91DFC;
    address constant public communityAddress = 0x008e9392ef82edBA2c45f2B02B9A21ac6B599BCA;


    // Mapping of supporters for random selection
    uint256 public donors = 0;
    mapping (address => bool) donated;
    mapping (uint256 => address) donorsList;


    // Fundraising finalization events
    event finishFundraiser(uint raised);
    event fundsToMSF(uint value);
    event fundsToCommunity(uint value);

    // Special events for a very special golden ticket!
    event goldenTicketFound(address winner);

    // Oraclize related events
    event newOraclizeQuery(string description);
    event newRate(string price);
    event newRandom(string price);

    function GratitudeCrowdsale(uint256 _startTime, uint256 _endTime, address _wallet)
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, _wallet)
    {
        owner = msg.sender;
        fundraising = true;
        tokensLeft = 500;
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        // Sign up first-time donors to the list + give them a nonce so they can win the golden ticket!
        if (!donated[beneficiary]) {
            donated[beneficiary] = true;
            donorsList[donors] = beneficiary;
            donors += 1;
        }

        // Check if there are still tokens left (otherwise skipped)
        if (tokensLeft > 0) {

            // See how many tokens can the donor get.
            uint256 toGet = howMany(msg.value);

            // If some, give the tokens to the donor.
            if (toGet > 0) {
                token.mint(beneficiary,toGet);
                TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
            }
        }

        // update state
        weiRaised = weiRaised.add(msg.value);
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
            return (100 finney, tokensLeft - 400);
        } else if (tokensLeft > 300) {
            return (200 finney, tokensLeft - 300);
        } else if (tokensLeft > 200) {
            return (300 finney, tokensLeft - 200);
        } else if (tokensLeft > 100) {
            return (400 finney, tokensLeft - 100);
        } else {
            return (500 finney, tokensLeft);
        }
    }

    function prepareFinalization() payable {
        // Owner check
        require(msg.sender == owner);

        // Check the fundraiser period is over
        require((now >= endTime) || (tokensLeft <= 0));

        // Make two Oraclize queries for ETHUSD rate and a random number
        getRateUSD();
        getRandom();

        // Helper boolen for the "finalizeFundraiser()" function
        fundraising = false;
    }

    function finalization() internal {
        // Check the "prepareFinalization" function was called
        require(!fundraising);

        // Check the rate was queried less then 1 hour ago
        // This check also proves that the rate was queried at all
        require((now - rateAge) <= 3600);

        // Check the random number was received
        require(haveRandom);
        token.giveGoldenTicket(donorsList[luckyNumber]);
        goldenTicketFound(donorsList[luckyNumber]);

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
            communityAddress.transfer(raisedWei - toCharity);
            fundsToCommunity(raisedWei - toCharity);
        } else {

            // If 2nd goal is met => send the rest above the 2nd goal to MSF
            charityShare = toPercentage(funding, funding-25000);
            toCharity = fromPercentage(raisedWei, charityShare);

            // Donate to charity first
            addressOfMSF.transfer(toCharity);
            fundsToMSF(toCharity);

            // Send funds to community;
            communityAddress.transfer(raisedWei - toCharity);
            fundsToCommunity(raisedWei - toCharity);
        }

        super.finalization();
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

    // <DATA FEEDS USING ORACLIZE>

    /**
     * @dev Create the ETHUSD query to Kraken thorough Oraclize
     */
    function getRateUSD() internal {

        //require(msg.sender == owner);
        oraclize_setProof(proofType_TLSNotary);
        if (oraclize.getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize: Insufficient funds!");
        } else {
            newOraclizeQuery("Oraclize was asked for ETHUSD rate.");
            qID1 = oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.p.1",300000);
        }
    }

    /**
     * @dev Create the random number query to Oraclize
     */
    function getRandom() internal {

        //require (msg.sender == owner);
        oraclize_setProof(proofType_Ledger);
        if (oraclize.getPrice("") > this.balance) {
            newOraclizeQuery("Oraclize: Insufficient funds!");
        } else {
            newOraclizeQuery("Oraclize was asked for a random number.");

            // Make query for 4 random bytes to potentially get a number between 0 and 4294967295.
            // The assumption is that there won't be more then 4294967295 participants.
            // This may potentially hurt your contract as the "random mod participants" result distribution is unequal.
            // There creates an incentive to join earlier to have an micro advantage.
            qID2 = oraclize_newRandomDSQuery(0, 4, 450000);
        }
    }

    /**
     *Oraclize callback function awaiting for response from the queries
     * @dev uses qType to handle the last called query type
     * @dev different querytypes shouldn't be called before callback was received
     * @dev -> not implementing a query que as "owner" is the only party responsible for creating order
     *      - BEAR THAT IN MIND
     */
    function __callback(bytes32 myid, string result, bytes proof) {
        require(msg.sender == oraclize_cbAddress());

        if (myid == qID1) {
            checkQueryA(myid, result, proof);
        } else if (myid == qID2) {
            checkQueryB(myid, result, proof);
        }
    }

    /**
     * A helper function to separate reaction to different Oraclize queries - ETHUSD rate
     * @dev reaction to ETHUSD rate oraclize callback - getRateUSD()
     * @dev sets global vars rate to the result and rateAge to current timeStamp
     * @param _myid 32 bytes identifying the query generated by Oraclize
     * @param _result string with query result by Oraclize
     * @param _proof byte array with the proof of source by Oraclize
     */
    function checkQueryA(bytes32 _myid, string _result, bytes _proof) internal {
        newRate(_result);

        // calling Oraclize string => uint256 converter for a number with 4 decimals
        rate = parseInt(_result,4);
        rateAge = now;
    }

    /**
     * A helper function to separate reaction to different Oraclize queries - random number
     * @dev reaction to random number oraclize callback - getRandom(number of participants)
     * @dev sets global var luckyNumber to the result
     * @param _myid 32 bytes identifying the query generated by Oraclize
     * @param _result string with query result by Oraclize
     * @param _proof byte array with the proof of source by Oraclize
     */
    function checkQueryB(bytes32 _myid, string _result, bytes _proof) internal oraclize_randomDS_proofVerify(_myid, _result, _proof) {
        newRandom(_result);

        // Calling Oraclize string => uint converter
        uint256 someNumber = parseInt(string(bytes(_result)),0);

        // Getting a luckyNumber between 0 and the number of donors (Random-number modulo number of donors)
        luckyNumber = someNumber%donors;
        haveRandom = true;
    }
}