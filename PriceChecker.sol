pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract PriceChecker is usingOraclize {
    using SafeMath for uint256;
    uint rate;
    uint rateAge;
    address owner;

    event newOraclizeQuery(string description);
    event newRateLoaded(string price);

    /**
     * @dev Create the ETHUSD query to Kraken though Oraclize
     * @dev TODO: add only owner modifier
     */
    function getRateUSD() internal {
        require(msg.sender == owner);
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        if (oraclize.getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.p.1");
        }
    }

    /**
     * @dev Oraclize callback function awaiting for response to our query
     */
    function __callback(bytes32 myid, string result, bytes proof) {
        require(msg.sender == oraclize_cbAddress());
        newRateLoaded("The rate is:" + result);
        // calling Oraclize string => uint256 converter for 4 decimal number
        rate = parseInt(result,4);
        rateAge = now;
    }

    /**
     * @dev Checking results of the fundraiser in USD
     * @return rated - total funds raised converted to USD
     */
    function checkResult() internal returns (uint){
        uint raised = this.balance;
        // convert wei => usd to perform checks
        uint rated = (raised.mul(rate)).div(10000000000000000000000);
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
     * @dev Counts the exacat amount of Wei to get send to the charity
     * @param total funds raised in Wei
     * @param percentage to be used obtained from the toPercentage(2) function
     * @return amount of Wei to be send to the charity
     */
    function fromPercentage(uint256 value, uint256 percentage) internal returns (uint256) {
        return (value*percentage)/100;
    }
}