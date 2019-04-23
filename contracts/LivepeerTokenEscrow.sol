pragma solidity ^0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

// TODO: Add option for payment and collateral to be ERC20 tokens
// TODO: Restrict time to fill committed purchase order to Livepeer unbonding period length.
contract LivepeerTokenEscrow { // is TimeDelayedOrderBook

    address private constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

    string internal constant ERROR_NOT_ORDER_OWNER = "ESCROW_NOT_PURCHASE_ORDER_OWNER";
    string internal constant ERROR_ORDER_COMMITTED_TO = "ESCROW_PURCHASE_COMMITTED_TO";
    string internal constant ERROR_INCORRECT_COLLATERAL = "ESCROW_INCORRECT_COLLATERAL";
    string internal constant ERROR_INCORRECT_ORDER_FILLER = "ESCROW_INCORRECT_ORDER_FILLER";

    struct PurchaseOrder {
        address purchaseOrderCreator;
        uint256 purchaseLptAmount;
        uint256 exchangeAmount;

        address collateralTokenAddress;
        uint256 collateralTokenAmount;

        bool committedTo;
        address committedFillerAddress;
    }

    uint256 newPurchaseOrderId;
    mapping(uint256 => PurchaseOrder) purchases;
    // Unnecessary if we have a front-end that monitors logs
    uint256[] purchaseOrderIds;
    IERC20 livepeerToken;
    uint256 timeToFillOrder;

    event NewPurchaseOrder(address indexed purchaseOrderCreator, uint256 purchaseOrderId);

    constructor(address _livepeerTokenAddress, uint256 _timeToFillOrder) public {
        livepeerToken = IERC20(_livepeerTokenAddress);
        // TODO: Get from Livepeer protocol?
        timeToFillOrder = _timeToFillOrder;
    }

    function createLptPurchaseOrder(uint256 _purchaseLptAmount, address _collateralTokenAddress, uint256 _collateralTokenAmount) public payable {
        PurchaseOrder memory purchase = PurchaseOrder(msg.sender, _purchaseLptAmount, msg.value, _collateralTokenAddress, _collateralTokenAmount, false, ZERO_ADDRESS);
        purchases[newPurchaseOrderId] = purchase;
        purchaseOrderIds.push(newPurchaseOrderId);

        emit NewPurchaseOrder(msg.sender, newPurchaseOrderId);

        newPurchaseOrderId++;
    }

    function cancelLptPurchaseOrder(uint256 _purchaseOrderId) public {
        PurchaseOrder storage purchase = purchases[_purchaseOrderId];

        require(purchase.purchaseOrderCreator == msg.sender, ERROR_NOT_ORDER_OWNER);
        require(purchase.committedTo == false, ERROR_ORDER_COMMITTED_TO);

        msg.sender.transfer(purchase.exchangeAmount);
        delete purchases[_purchaseOrderId];
        // TODO: DELETE FROM purchaseOrderIds
    }

    function commitToLptPurchaseOrder(uint256 _purchaseOrderId) public payable {
        PurchaseOrder storage purchase = purchases[_purchaseOrderId];

        require(purchase.committedTo == false, ERROR_ORDER_COMMITTED_TO);
        require(purchase.collateralTokenAmount == msg.value, ERROR_INCORRECT_COLLATERAL);

        purchase.committedTo = true;
        purchase.committedFillerAddress = msg.sender;
    }

    function fillLptPurchaseOrder(uint256 _purchaseOrderId) public {
        PurchaseOrder storage purchase = purchases[_purchaseOrderId];

        require(purchase.committedFillerAddress == msg.sender, ERROR_INCORRECT_ORDER_FILLER);
        // TODO: SafeTransferFrom?
        livepeerToken.transferFrom(msg.sender, purchase.purchaseOrderCreator, purchase.purchaseLptAmount);

        delete purchases[_purchaseOrderId];
        // TODO: DELETE FROM purchaseOrderIds
    }
}
