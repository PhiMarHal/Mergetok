# MERGETOK

A contract to create and merge ERC20 tokens, on the Kiln testnet.<hr>

CURRENT DEPLOYMENT: https://explorer.kiln.themerge.dev/address/0x17379798be91a5E43D0991dff565C26Ff17b4261/transactions

BASIC UI: https://beta.oneclickdapp.com/garage-laser (needed for create token, but needs a refresh after each tx)

or https://oneclickdapp.com/lesson-door

<hr>

<h3>How do I use this?</h3>

If you haven't done so, add the Kiln testnet to your Metamask networks. https://kiln.themerge.dev/

You'll also want to get some ether from the faucet.

<h4>WRITE FUNCTIONS</h4>

> <b>createToken</b>: creates a new ERC20 token and sends you tokens according to the ETH you spend (1 ETH = 1 000 000 tokens).

If the symbol you pick already exists, you will get tokens from that previously created token.

Note: ETH has 18 decimals. If you want to send 1 ETH (rather than 1 wei), type "1000000000000000000" in the value field.

> <b>mergeToken</b>: merges two tokens to build a new token contract, and sends you the resulting tokens.

You must provide an equal amount of tokens for tokenA and tokenB.

> <b>claimRandomToken</b>: get a random token from the contract's reserves.

Gives half of remaining reserves for that token. Use this to get tokens quickly. 

> <b>claimSpecificToken</b>: get a specific token from the contract's reserves.

Same as claimRandomToken, except for a specific token address.

> <b>seedToken</b>: give the contract a token

If you want others to use your tokens, you can seed the contract directly.


<h4>READ FUNCTIONS</h4>

> <b>createdTokensArray</b>: all created tokens, basic or merged. 
 
Starts at 0.

> <b>createdTokensSymbol</b>: all used symbols. 
 
If the function returns the 0x0000... address, then the symbol is available.

> <b>mergedTier</b>: tier for any token.

Default is 0. To gain a tier, the tokens merged must be of the same tier (0 + 0 = 1, 1 + 1 = 2... but 1 + 0 = 1, 2 + 1 = 2).

> <b>seededTokensAmount</b>: number of tokens available for a given token address

The contract sends half of this balance with each claim.

> <b>seededTokensArray</b>: all seeded tokens.

Starts at 0.
