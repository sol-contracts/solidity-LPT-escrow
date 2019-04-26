pragma solidity ^0.5.7;

import "../TimeDelayedOrderBook.sol";

contract TimeDelayedOrderBookMock is TimeDelayedOrderBook {

    function blocksToFillOrder() public view returns (uint256) {
        return 10;
    }
}
