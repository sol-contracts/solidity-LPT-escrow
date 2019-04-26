pragma solidity ^0.5.7;

import "../TimeDelayedOrderBook.sol";

contract TimeDelayedOrderBookMock is TimeDelayedOrderBook {

    function blocksToFillOrder() public view returns (uint256) {
        return 10;
    }

    function createPurchaseOrder(
        address _purchaseToken,
        uint256 _purchaseValue,
        address _paymentToken,
        uint256 _paymentValue,
        address _collateralToken,
        uint256 _collateralValue
    )
        public
        payable
        returns (uint256)
    {
        _createPurchaseOrder(_purchaseToken, _purchaseValue, _paymentToken, _paymentValue, _collateralToken, _collateralValue);
    }
}
