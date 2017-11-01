pragma solidity ^0.4.11;

import 'github.com/OpenZeppelin/contracts/token/MintableToken.sol';

// Standard token variables
contract TokenOfGratitude {
    string constant public name = "Token Of Gratitude";
    string constant public symbol = "ToG";
    uint8 constant public decimals = 0;
    uint256 public totalSupply = 0;

    uint256 public constant maxSupply = 500;
    uint256 public expirationDate = 1672531199;
    address public goldenTicketOwner;

    // Mappings for easier backchecking
    mapping (address => uint) redeemed;

    // Golden ticket related events
    event goldenTicketMoved(address indexed newOwner);
    event goldenTicketUsed(address charlie, string message);

    function TokenOfGratitude() {
        goldenTicketOwner = msg.sender;
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

}