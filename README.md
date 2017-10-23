# Token of Gratitude - Community fundraiser

The main goal of the project is to raise funds to drive the community efforts in Prague, Czech Republic, EU.

The side effects are the following:
 - show how/that any token sale can be extended to contribute to the common good.
 - use a virtual token for real life networking
 - use a virtual token as a proof to get an off chain reward

#### Token specification (ERC20)
- Name: Token of Gratitude
- Symbol: ToG
- Total supply: 500
- Decimals: 0

Additional specs:
- Token value/usage:
    - 1 ToG = 1 drink + chat (optional) &
    - free hub entry for 1 year (goal 1) &
    - entry discount for the 2018 conference (goal 2) &
    - great feeling forever after;
- Usability location:
    - Prague, Czech Republic, EU +
    - special occasions such as DEVCON (to get the drink)
- Token expiration: 5 years
- **One** randomly selected winner of a **Golden ticket**:
    - randomly selected among all contributors (not only ToG holders)
    - 1 fancy lunch/dinner in Prague
    - free access to the hub forever (goal 1)
    - free entry for the 2018 conference (goal 2)
    - does not expire!
    - is transferable if not used

#### Funding goal specification
If a certain amount of money is raised I commit myself to the following:
1. If 10000 USD is raised, I'll open up a community developer coworking hub in Prague, where anyone will be able to work on blockchain related projects. There will be free entry for ToG redeemers for 1 year upon redemption.
2. If 25000 USD is raised, I'll do the 1. AND I'll organize an academic conference in Prague, where researchers will have a chance to present their blockchain related academic papers.
3. Anything raised bellow the goals or above 25k USD will be automatically send to Ethereum account of Doctors without borders / Médecins Sans Frontières (MSF)

The MSF donation is strictly coded in the contract using Oraclize service to perform the current exchange rate check.
Here is the link to MSF (Czech Republic) public Ethereum address: https://www.lekari-bez-hranic.cz/en/bank-details#cryptocurrencies

### Token price
The price is given for each set of 100 tokens as follows:
 1. 100 tokens at 0.1 eth each
 2. 100 tokens at 0.2 eth each
 3. 100 tokens at 0.3 eth each
 4. 100 tokens at 0.4 eth each
 5. 100 tokens at 0.5 eth each

 Current price is accessible though an constant public function and will be visible on the website.
 It's possible to buy more then 100 tokens at once - the price will be recounted according to the value of the transaction.
 Anything send above the current token price will be considered a donation.

### Token usability
In any case the tokens can be redeemed for a drink (beer price range).

If the first goal is met, any ToG redeemer will have a free entry into the hub for one year.

If the second goal is met, any ToG redeemer will get an priority invitation for paper submition and at least 33% discount off the conference ticket price (ticket prices are however unknown for now).


**When is it possible to reedem your token for a drink?**
Anytime we come across each other. You will have to leave me your encrypted contact in the message during redeeming your ToG (can be a single purposed email or whatever).
I'll react asap and we can schedule a meeting - once the hub is open this should be much more easier.
Expiration of the token is 5 years!

**Where is it possible to redeem the token?**

* Mostly in Prague, Czech Republic
* Between 31.10. -  4.11.2017 in Cancún, Mexico (DEVCON3)
* More locations can be reported on twitter as I move

**How is it possible to redeem the token?**

If you are a token holder, use the "redeem(string message)" function of the contract to send me an encrypted message with your contact details (can be a one purpuse email, signal, telegram, facebook,...).
The redeem service (with encryption) will be available on the website sometime during the sale.
TODO: choose an encryption method

# Terms & Conditions (Participation rules)
By participating in the fundraiser you ("The Participant") agree with following:
1. All contributions are voluntary and non refundable.
1. The cause of this fundraiser isn't sale of a product or service.
1. The cause of this fundraiser is to experiment with community crowdsourcing posibilities.
1. The Initiating party won't use any collected funds as a reward for itself.
1. After the fundraiser is over, any expense larger than 100 USD made from the community account will be documented and explained publicly.
1. Any promise made in the fundraiser isn't legally enforceable in any jurisdiction know to men yet and thus fullfiling of those promises lie solely on the reputation of the party Initiating it.
1. The Participant agrees to publicly shame the Initiating party in case of miss conduct of the initiating party related to the this fundraiser.
1. The jurisdiction for a potential legal dispute is herby the free planet of Mars (If you want to sue me, first get there).
1. The Initiating party reserves the right to defend itself in a hypotetical Twitter flamewar.
1. The Participant agrees to call his/her parents immediately, without an unreasonable delay after participating in the fundraiser.
## <sup>not really</sup> FAQ
**Q:** Is the fundraiser running on Ethereum or EthereumClassic?

**A:** Currently it's only Ethereum. Fundraiser on Ethereum Classic may however happen if there will be enough demand.
___
**Q:** Will my token be redeemable on future forks?

**A:** Unfortunately, no. I will most likely honor only the tokens on the fork with highest market cap of tradable ethers.
___
**Q:** Will the money raised be used to pay for the beers?

**A:** No, all the money will be used for the community cause or charity.

