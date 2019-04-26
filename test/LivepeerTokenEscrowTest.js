const LivepeerTokenEscrow = artifacts.require('LivepeerTokenEscrow')

contract('LivepeerTokenEscrow', accounts => {

    let livepeerTokenEscrow

    beforeEach(async () => {
        livepeerTokenEscrow = await LivepeerTokenEscrow.new()
    })

    context('createOrderOfLptForEthWithEthCollateral(uint256 _purchaseValue, uint256 _collateralValue)', () => {

    })

})