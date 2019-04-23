pragma solidity ^0.5.7;

import "../TimeDelayedOrderBook.sol";

contract TimeDelayedOrderBookMock is TimeDelayedOrderBook {

    uint256 private constant TIME_TO_FILL_ORDER = 3000000000000000000;

    function timeToFillOrder() public returns (uint256) {
        return TIME_TO_FILL_ORDER; // 3 tokens
    }
}
