const LivepeerTokenEscrow = artifacts.require('LivepeerTokenEscrow')

contract('LivepeerTokenEscrow', accounts => {

    let livepeerTokenEscrow

    beforeEach(async () => {
        livepeerTokenEscrow = await LivepeerTokenEscrow.new()
    })


})