pragma solidity ^0.5.7;

import "./TimeDelayedOrderBook.sol";

contract LivepeerTokenEscrow is TimeDelayedOrderBook {

    function timeToFillOrder() public returns (uint256) {
        return 3000000000000000000;
    }

}
