pragma solidity ^0.5.7;

import "./TimeDelayedOrderBook.sol";
import "./IController.sol";
import "./IBondingManager.sol";
import "./IRoundsManager.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract LivepeerTokenEscrow is TimeDelayedOrderBook {

    using SafeMath for uint256;

    address public livepeerToken;

    IController public livepeerController;

    constructor (address _livepeerController) public {
        livepeerController = IController(_livepeerController);
    }

    function createOrderOfLptForEthWithEthCollateral(uint256 _purchaseValue, uint256 _collateralValue) public payable {
        address livepeerTokenAddress = _getLivepeerContractAddress("LivepeerToken");
        createPurchaseOrder(livepeerTokenAddress, _purchaseValue, ETH_TOKEN_IDENTIFIER, msg.value, ETH_TOKEN_IDENTIFIER, _collateralValue);
    }

    function createOrderOfLptForEthWithTokenCollateral(uint256 _purchaseValue, address _collateralToken, uint256 _collateralValue)
        public
        payable
    {
        address livepeerTokenAddress = _getLivepeerContractAddress("LivepeerToken");
        createPurchaseOrder(livepeerTokenAddress, _purchaseValue, ETH_TOKEN_IDENTIFIER, msg.value, _collateralToken, _collateralValue);
    }

    function createOrderOfLptForTokenWithTokenCollateral(
        uint256 _purchaseValue,
        address _paymentToken,
        uint256 _paymentValue,
        address _collateralToken,
        uint256 _collateralValue
    )
        public
        payable
    {
        address livepeerTokenAddress = _getLivepeerContractAddress("LivepeerToken");
        createPurchaseOrder(livepeerTokenAddress, _purchaseValue, _paymentToken, _paymentValue, _collateralToken, _collateralValue);
    }

    function blocksToFillOrder() public view returns (uint256) {
        IBondingManager bondingManager = IBondingManager(_getLivepeerContractAddress("BondingManager"));
        uint64 unbondingPeriodRounds = bondingManager.unbondingPeriod();

        IRoundsManager roundsManager = IRoundsManager(_getLivepeerContractAddress("RoundsManager"));
        uint256 roundLength = roundsManager.roundLength();

        return roundLength.mul(unbondingPeriodRounds);
    }

    function _getLivepeerContractAddress(string memory livepeerContract) internal view returns (address) {
        bytes32 contractId = keccak256(abi.encodePacked(livepeerContract));
        return livepeerController.getContract(contractId);
    }
}
