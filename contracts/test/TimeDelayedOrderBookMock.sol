pragma solidity ^0.5.7;

import "../TimeDelayedOrderBook.sol";

contract TimeDelayedOrderBookMock is TimeDelayedOrderBook {

    function timeToFillOrder() public view returns (uint256) {
        return 1 days;
    }
}
