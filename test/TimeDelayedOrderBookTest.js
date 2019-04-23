const TimeDelayedOrderBookMock = artifacts.require('TimeDelayedOrderBookMock')
const Erc20Token = artifacts.require('ERC20')
const BN = require('bn.js')

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
const ETH_TOKEN_IDENTIFIER = '0x0000000000000000000000000000000000000000'

const getLog = (receipt, logName, argName) => {
    const log = receipt.logs.find(({ event }) => event == logName)
    return log ? log.args[argName] : null
}

const assertEqualBN = async (actualPromise, expected, message) =>
    assert.equal((await actualPromise).toNumber(), expected, message)

const assertLogs = async (receiptPromise, ...logNames) => {
    const receipt = await receiptPromise
    for (const logName of logNames) {
        assert.isNotNull(getLog(receipt, logName), `Expected ${logName} in receipt`)
    }
}

contract('TimeDelayedOrderBook', ([purchaseOrderCreator]) => {

    let timeDelayedOrderBook
    let purchaseToken, paymentToken, collateralToken

    beforeEach(async () => {
        timeDelayedOrderBook = await TimeDelayedOrderBookMock.new()
        purchaseToken = await Erc20Token.new()
        paymentToken = await Erc20Token.new()
        collateralToken = await Erc20Token.new()
    })

    context('createPurchaseOrder(address _purchaseToken, uint256 _purchaseValue, address _paymentToken, ' +
        'address _paymentValue, address _collateralToken, uint256 _collateralValue)', () => {

        const purchaseValue = 30
        const paymentValue = 20
        const collateralValue = 10

        let orderId

        beforeEach(async () => {
            const createOrderReceipt = await timeDelayedOrderBook.createPurchaseOrder(
                purchaseToken.address, purchaseValue, ETH_TOKEN_IDENTIFIER, paymentValue, collateralToken.address, collateralValue,
                { value: paymentValue, from: purchaseOrderCreator });

            orderId = getLog(createOrderReceipt, 'NewPurchaseOrder', 'purchaseOrderId')
        })

        it('creates a new purchase order with ID 0', async () => {
            const expectedTimeToFillOrder = 0

            const purchaseOrder = await timeDelayedOrderBook.purchaseOrders(orderId)

            assert.strictEqual(purchaseOrder.purchaseOrderCreator, purchaseOrderCreator)
            assert.strictEqual(purchaseOrder.purchaseToken, purchaseToken.address)
            await assertEqualBN(purchaseOrder.purchaseValue, purchaseValue)
            assert.strictEqual(purchaseOrder.paymentToken, ETH_TOKEN_IDENTIFIER)
            await assertEqualBN(purchaseOrder.paymentValue, paymentValue)
            assert.strictEqual(purchaseOrder.collateralToken, collateralToken.address)
            await assertEqualBN(purchaseOrder.collateralValue, collateralValue)
            assert.isFalse(purchaseOrder.committedTo)
            assert.strictEqual(purchaseOrder.committedFillerAddress, ZERO_ADDRESS)
            await assertEqualBN(purchaseOrder.timeToFillOrder, expectedTimeToFillOrder)
        })
    })
})