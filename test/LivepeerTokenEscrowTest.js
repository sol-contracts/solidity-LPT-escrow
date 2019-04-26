const LivepeerTokenEscrow = artifacts.require('LivepeerTokenEscrow')
const ControllerMock = artifacts.require('ControllerMock')
const TestErc20 = artifacts.require('TestErc20')
const BondingManagerMock = artifacts.require('BondingManagerMock')
const RoundsManagerMock = artifacts.require('RoundsManagerMock')
const {getLog, assertEqualBN} = require('./helpers')

const ETH_TOKEN_IDENTIFIER = '0x0000000000000000000000000000000000000000'
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
const DEFAULT_FILL_ORDER_BY_BLOCK = 0

contract('LivepeerTokenEscrow', ([purchaseOrderCreator]) => {

    this.unbondingPeriodRounds = 7
    this.roundLengthBlocks = 5760

    this.purchaseValue = 50
    this.paymentValue = 30
    this.collateralValue = 10

    beforeEach(async () => {
        this.livepeerToken = await TestErc20.new()
        this.paymentToken = await TestErc20.new()
        this.collateralToken = await TestErc20.new()
        const bondingManager = await BondingManagerMock.new(this.unbondingPeriodRounds)
        const roundsManager = await RoundsManagerMock.new(this.roundLengthBlocks)
        const controller = await ControllerMock.new(this.livepeerToken.address, bondingManager.address, roundsManager.address)
        this.livepeerTokenEscrow = await LivepeerTokenEscrow.new(controller.address)
    })

    it('returns correct blocksToFillOrder()', async() => {
        const expectedBlocksToFillOrder = this.unbondingPeriodRounds * this.roundLengthBlocks

        const actualBlocksToFillOrder = await this.livepeerTokenEscrow.blocksToFillOrder()

        assert.strictEqual(actualBlocksToFillOrder.toNumber(), expectedBlocksToFillOrder)
    })

    context('creates purchase order with correct details with', () => {

        it('createOrderOfLptForEthWithEthCollateral(_purchaseValue, _collateralValue)', async () => {
            const createOrderReceipt = await this.livepeerTokenEscrow.createOrderOfLptForEthWithEthCollateral(
                this.purchaseValue, this.collateralValue, { value: this.paymentValue })

            const orderId = getLog(createOrderReceipt, 'NewPurchaseOrder', 'purchaseOrderId')
            const {
                purchaseOrderCreator: actualPurchaseOrderCreator,
                purchaseToken,
                purchaseValue,
                paymentToken,
                paymentValue,
                collateralToken,
                collateralValue,
                committedFillerAddress,
                fillOrderByBlock
            } = await this.livepeerTokenEscrow.purchaseOrders(orderId)

            assert.strictEqual(actualPurchaseOrderCreator, purchaseOrderCreator)
            assert.strictEqual(purchaseToken, this.livepeerToken.address)
            await assertEqualBN(purchaseValue, this.purchaseValue)
            assert.strictEqual(paymentToken, ETH_TOKEN_IDENTIFIER)
            await assertEqualBN(paymentValue, this.paymentValue)
            assert.strictEqual(collateralToken, ETH_TOKEN_IDENTIFIER)
            await assertEqualBN(collateralValue, this.collateralValue)
            assert.strictEqual(committedFillerAddress, ZERO_ADDRESS)
            await assertEqualBN(fillOrderByBlock, DEFAULT_FILL_ORDER_BY_BLOCK)
        })

        it('createOrderOfLptForEthWithTokenCollateral(_purchaseValue, _collateralToken, _collateralValue)', async () => {
            const createOrderReceipt = await this.livepeerTokenEscrow.createOrderOfLptForEthWithTokenCollateral(
                this.purchaseValue, this.collateralToken.address, this.collateralValue, { value: this.paymentValue })

            const orderId = getLog(createOrderReceipt, 'NewPurchaseOrder', 'purchaseOrderId')
            const {
                purchaseOrderCreator: actualPurchaseOrderCreator,
                purchaseToken,
                purchaseValue,
                paymentToken,
                paymentValue,
                collateralToken,
                collateralValue,
                committedFillerAddress,
                fillOrderByBlock
            } = await this.livepeerTokenEscrow.purchaseOrders(orderId)

            assert.strictEqual(actualPurchaseOrderCreator, purchaseOrderCreator)
            assert.strictEqual(purchaseToken, this.livepeerToken.address)
            await assertEqualBN(purchaseValue, this.purchaseValue)
            assert.strictEqual(paymentToken, ETH_TOKEN_IDENTIFIER)
            await assertEqualBN(paymentValue, this.paymentValue)
            assert.strictEqual(collateralToken, this.collateralToken.address)
            await assertEqualBN(collateralValue, this.collateralValue)
            assert.strictEqual(committedFillerAddress, ZERO_ADDRESS)
            await assertEqualBN(fillOrderByBlock, DEFAULT_FILL_ORDER_BY_BLOCK)
        })

        it('createOrderOfLptForTokenWithTokenCollateral(purchaseValue, paymentToken, paymentValue, collateralToken, collateralValue)', async () => {
            await this.paymentToken.approve(this.livepeerTokenEscrow.address, this.paymentValue)

            const createOrderReceipt = await this.livepeerTokenEscrow.createOrderOfLptForTokenWithTokenCollateral(
                this.purchaseValue, this.paymentToken.address, this.paymentValue, this.collateralToken.address, this.collateralValue)

            const orderId = getLog(createOrderReceipt, 'NewPurchaseOrder', 'purchaseOrderId')
            const {
                purchaseOrderCreator: actualPurchaseOrderCreator,
                purchaseToken,
                purchaseValue,
                paymentToken,
                paymentValue,
                collateralToken,
                collateralValue,
                committedFillerAddress,
                fillOrderByBlock
            } = await this.livepeerTokenEscrow.purchaseOrders(orderId)

            assert.strictEqual(actualPurchaseOrderCreator, purchaseOrderCreator)
            assert.strictEqual(purchaseToken, this.livepeerToken.address)
            await assertEqualBN(purchaseValue, this.purchaseValue)
            assert.strictEqual(paymentToken, this.paymentToken.address)
            await assertEqualBN(paymentValue, this.paymentValue)
            assert.strictEqual(collateralToken, this.collateralToken.address)
            await assertEqualBN(collateralValue, this.collateralValue)
            assert.strictEqual(committedFillerAddress, ZERO_ADDRESS)
            await assertEqualBN(fillOrderByBlock, DEFAULT_FILL_ORDER_BY_BLOCK)
        })
    })

})