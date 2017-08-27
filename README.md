# Initial Beer Offering (IBO)

The purpose of this project is to raise funds to drive the community efforts in Prague, Czech Republic, EU.

The side effect of the this project are the following:
 - show how/that any ICO can be extended to contribute to the common good.
 - use a virtual token to real life networking


#### Token specification
- Name: Token of Gratitude
- Symbol: ToG
- Total supply: 500
- Decimals: 0

additional specs:
- Token usage value: 1 ToG = 1 beer + chat (optional)
- Usability location: Prague, Czech Republic, EU (+ special occasions such as DEVCON)
- Token expiration: 5 years

#### Funding goal specification
If a certain amount of money is raised I commit myself to the following:
1. If 10000 USD is raised, I'll open up a community developer hub in Prague, where anyone will be able to work on blockchain related projects. I'll run it for free for a complete year 2018.
2. If 25000 USD is raised, I'll do the 1. AND I'll organize an academic conference in Prague, where researchers will have a chance to present their blockchain related academic papers.
3. Anything raised above 25k USD will be automatically send to Ethereum account of Doctors without borders / Médecins Sans Frontières (MSF)

The MSF donation is strictly coded in the contract using Oraclize service to perform the current exchange rate check.
Here is the link to MSF public Ethereum address:
TODO: Get a link from MSF

### Token price
The price is given for each set of 100 tokens as follows:
 1. 100 tokens at 0,1 eth each
 2. 100 tokens at 0,2 eth each
 3. 100 tokens at 0,5 eth each
 4. 100 tokens at 0,75 eth each
 5. 100 tokens at 1 eth each

 Current price is accessible though an constant public function and will be visible on the website.
 It's possible to buy more then 100 tokens at once - the price will be recounted according to the value of the transaction
 Anything send above the current token price will be considered a donation.

### Token usability
The tokens can be redeemed for a beer. Yes, an actual physical possibly drought beer.
Basically, I'll get you a drink and we can have a chat about crypto or whatever.
Or you can just tell me to leave after. Well, that's up to you!

**When is it possible to reedem your token?**

Anytime we come across each other.
Expiration of the token is 5 years!

**Where is it possible to redeem the token?**

* Mostly in Prague, Czech Republic
* Between 31.10. -  4.11.2017 in Cancún, Mexico (DEVCON3)
* More locations can be reported on twitter as I move

**How is it possible to redeem the token?**

If you are a token holder, use the "redeem(string message)" function of the contract to send me an encrypted message with your contact and a medium (telegram, facebook,...).
The redeem service (with encryption) will be available on the website sometime during the sale.
TODO: choose an encryption method

## <sup>not really</sup> FAQ
**Q:** Is the fundraiser running on Ethereum or EthereumClassic?

**A:** Currently it's only Ethereum. Fundraiser on Ethereum Classic will likely start
 with a slight delay and adjusted price/goals based on the participation on the ETH contract.
___
**Q:** Will my token be redeemable on future forks?

**A:** Unfortunately, no. I will most likely honor only the tokens on the fork with highest market cap of tradable ethers.
___
**Q:** Will the money raised be used to pay for the beers?

**A:** No, all the money will be used for the community cause.
My financial contribution is therefore theoretically something around 1000 USD.
if I count 500 * 2 USD for the beers I promise to get you, considering
an average price of a decent large drought beer in Prague
(Some people may of course never redeem their tokens but on the other hand
 the price of a beer is likely to rise over the next 5 years)
___

