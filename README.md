# blockhouse-contract
 
Look at the bond_v2 contract

Has functionality for maturity dates and yield payouts, doesn't take into account more realistic things like bond value and things like that. 

Essentially just allows someone to specify a market cap and the token that they want to accept, and the rest can be handled externally. 

I.E. If you want to represent a bond that is sold for 1000 dollars you simply set the acceptedToken to something like USDC and the supply cap to 1000, and people are able to fractionalize that at will. I'd need to do testing to make sure but I believe that the bond issuer can just deposit their total yield payment and the contract should split it up accordingingly to each holder. 

Further work includes morphing into a factory contract so something does not need to be deployed for each individual bond and looking further into the 4626 standard to see if that could be a better solution (I don't think it will be as I don't think you can trade the shares as tokens under that standard, whereas this would allow someone to buy and sell fractions of a bond).