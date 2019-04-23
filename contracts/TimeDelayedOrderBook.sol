pragma solidity ^0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

// TODO: Add option for payment and collateral to be ERC20 tokens
// TODO: Restrict time to fill committed purchase order to Livepeer unbonding period length.
// TODO: Safe token transfers.
contract TimeDelayedOrderBook {

    address private constant ETH_TOKEN_IDENTIFIER = address(0);
    uint256 private constant DEFAULT_TIME_TO_FILL_ORDER = 0;

    string internal constant ERROR_INCORRECT_PAYMENT_VALUE = "ESCROW_INCORRECT_PAYMENT_VALUE";
    string internal constant ERROR_NOT_ORDER_OWNER = "ESCROW_NOT_PURCHASE_ORDER_OWNER";
    string internal constant ERROR_ORDER_COMMITTED_TO = "ESCROW_PURCHASE_COMMITTED_TO";
    string internal constant ERROR_INCORRECT_COLLATERAL = "ESCROW_INCORRECT_COLLATERAL";
    string internal constant ERROR_INCORRECT_ORDER_FILLER = "ESCROW_INCORRECT_ORDER_FILLER";

    struct PurchaseOrder {
        address purchaseOrderCreator;

        address purchaseToken;
        uint256 purchaseValue;

        address paymentToken;
        uint256 paymentValue;

        address collateralToken;
        uint256 collateralValue;

        bool committedTo;
        address committedFillerAddress;
        uint256 timeToFillOrder;
    }

    uint256 private newPurchaseOrderId;
    mapping(uint256 => PurchaseOrder) public purchaseOrders;
    // Unnecessary if we have a front-end that monitors logs
    uint256[] public purchaseOrderIds;

    event NewPurchaseOrder(address indexed purchaseOrderCreator, uint256 purchaseOrderId);

    function createPurchaseOrder(
        address _purchaseToken, // Can't be the ETH address
        uint256 _purchaseValue,
        address _paymentToken,
        uint256 _paymentValue,
        address _collateralToken,
        uint256 _collateralValue
    )
        public
        payable
    {
        if (_paymentToken == ETH_TOKEN_IDENTIFIER) {
            require(msg.value == _paymentValue, ERROR_INCORRECT_PAYMENT_VALUE);
        } else {
            IERC20(_paymentToken).transferFrom(msg.sender, address(this), _paymentValue);
        }

        PurchaseOrder memory purchaseOrder = PurchaseOrder(
            msg.sender,
            _purchaseToken,
            _purchaseValue,
            _paymentToken,
            _paymentValue,
            _collateralToken,
            _collateralValue,
            false,
            address(0),
            DEFAULT_TIME_TO_FILL_ORDER
        );

        purchaseOrders[newPurchaseOrderId] = purchaseOrder;
        purchaseOrderIds.push(newPurchaseOrderId);

        emit NewPurchaseOrder(msg.sender, newPurchaseOrderId);

        newPurchaseOrderId++;
    }

    function cancelPurchaseOrder(uint256 _purchaseOrderId) public {
        PurchaseOrder storage purchaseOrder = purchaseOrders[_purchaseOrderId];

        require(purchaseOrder.purchaseOrderCreator == msg.sender, ERROR_NOT_ORDER_OWNER);
        require(purchaseOrder.committedTo == false, ERROR_ORDER_COMMITTED_TO);

        if (purchaseOrder.paymentToken == ETH_TOKEN_IDENTIFIER) {
            msg.sender.transfer(purchaseOrder.paymentValue);
        } else {
            IERC20(purchaseOrder.paymentToken).transfer(msg.sender, purchaseOrder.paymentValue);
        }

        delete purchaseOrders[_purchaseOrderId];
        // TODO: DELETE FROM purchaseOrderIds
    }

    /*
     * Should check purchaseOrder.purchaseToken is as expected before calling this,
     * otherwise the seller could commit to an order they cannot fill.
     */
    function commitToPurchaseOrder(uint256 _purchaseOrderId) public payable {
        PurchaseOrder storage purchaseOrder = purchaseOrders[_purchaseOrderId];

        require(purchaseOrder.committedTo == false, ERROR_ORDER_COMMITTED_TO);
        if (purchaseOrder.collateralToken == ETH_TOKEN_IDENTIFIER) {
            require(purchaseOrder.collateralValue == msg.value, ERROR_INCORRECT_COLLATERAL);
        } else {
            IERC20(purchaseOrder.collateralToken).transferFrom(msg.sender, address(this), purchaseOrder.collateralValue);
        }

        purchaseOrder.committedTo = true;
        purchaseOrder.committedFillerAddress = msg.sender;
    }

    function fillPurchaseOrder(uint256 _purchaseOrderId) public {
        PurchaseOrder storage purchaseOrder = purchaseOrders[_purchaseOrderId];

        require(purchaseOrder.committedFillerAddress == msg.sender, ERROR_INCORRECT_ORDER_FILLER);

        if (purchaseOrder.paymentToken == ETH_TOKEN_IDENTIFIER) {
            msg.sender.transfer(purchaseOrder.paymentValue);
        } else {
            IERC20(purchaseOrder.paymentToken).transfer(msg.sender, purchaseOrder.paymentValue);
        }

        IERC20(purchaseOrder.purchaseToken).transferFrom(msg.sender, purchaseOrder.purchaseOrderCreator, purchaseOrder.purchaseValue);

        delete purchaseOrders[_purchaseOrderId];
        // TODO: DELETE FROM purchaseOrderIds
    }

    function timeToFillOrder() public returns (uint256);
}
