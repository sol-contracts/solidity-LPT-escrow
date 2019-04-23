# Livepeer Token Escrow Contract

A contract for securing the purchase of Livepeer Tokens from an account that is currently bonded to the Livepeer network. 

Livepeer accounts that are bonded to the Livepeer network must currently wait 7 days to unbond their tokens before they can be transferred to a new owner. This contract ensures that once a seller of LPT has committed to selling LPT, they are incentivised not to withdraw there commitment during the unbonding period by putting up collateral which they will loose if they don't finalise the deal. The buyers payment is locked from the point a seller commits to selling LPT. 
