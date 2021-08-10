// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Swap is Ownable {
    using SafeMath for uint256;

    IERC20 Gold;
    IERC20 Silver;

    uint256 public ratioEthToGold;
    uint256 public ratioEthToSilver;

    bytes32 private EthToGold = keccak256("Swap(ETH, Gold)");
    bytes32 private EthToSilver = keccak256("Swap(ETH, Silver)");

    bytes32 private GoldToEth = keccak256("Swap(Gold, ETH)");
    bytes32 private SilverToETh = keccak256("Swap(Silver, ETH)");
    bytes32 private SilverToGold = keccak256("Swap(Silver, Gold)");
    bytes32 private GoldToSilver = keccak256("Swap(Gold, Silver)");

    /// @notice Event emitted only on construction.
    event SwapDeployed();

    /// @notice Event emitted when ETH to token swap finished.
    event EthToTokenSwapped(bytes32 _type, uint256 _amount);

    /// @notice Event emitted when token to token or token to ETH swap finished.
    event TokenToEthAndTokenToTokenSwapped(bytes32 _type, uint256 _amount);

    /// @notice Event emitted when ETH to token ratio changed.
    event TokenRatioChanged(
        uint256 _newRatioEthToGold,
        uint256 _newRatioEthToSilver
    );

    /**
     * @dev Constructor function
     * @param _Gold Interface of Gold token
     * @param _Silver Interface of Silver token
     * @param _ratioEthToGold Ratio between ETH and Gold
     * @param _ratioEthToSilver Ratio between ETH and Silver
     */
    constructor(
        IERC20 _Gold,
        IERC20 _Silver,
        uint256 _ratioEthToGold,
        uint256 _ratioEthToSilver
    ) {
        Gold = _Gold;
        Silver = _Silver;
        ratioEthToGold = _ratioEthToGold;
        ratioEthToSilver = _ratioEthToSilver;

        emit SwapDeployed();
    }

    /**
     * @dev Payable function to swap ETH to token
     * @param _type Token type which should be swapped
     * @param _amount Token amount
     */
    function swapEthFor(bytes32 _type, uint256 _amount) external payable {
        if (_type == EthToGold) {
            require(
                ratioEthToGold * _amount == msg.value,
                "Swap: Caller hasn't got enough ETH for buying Gold token"
            );
            Gold.transfer(msg.sender, _amount);
        }
        if (_type == EthToSilver) {
            require(
                ratioEthToSilver * _amount == msg.value,
                "Swap: Caller hasn't got enough ETH for buying Silver token"
            );
            Silver.transfer(msg.sender, _amount);
        }

        emit EthToTokenSwapped(_type, _amount);
    }

    /**
     * @dev External function to swap token to ETH and token to token
     * @param _type Token type which should be swapped
     * @param _amount Token Amount
     */
    function swapTokenFor(bytes32 _type, uint256 _amount) external {
        if (_type == GoldToEth) {
            Gold.transferFrom(msg.sender, address(this), _amount);
            payable(msg.sender).transfer(_amount * ratioEthToGold);
        } else if (_type == SilverToETh) {
            Silver.transferFrom(msg.sender, address(this), _amount);
            payable(msg.sender).transfer(_amount * ratioEthToSilver);
        } else if (_type == GoldToSilver) {
            Gold.transferFrom(msg.sender, address(this), _amount);

            uint256 silverToGold = ratioEthToSilver * 1000 / ratioEthToGold;
            Silver.transfer(
                msg.sender,
                _amount * silverToGold / 1000
            );
        } else if (_type == SilverToGold) {
            Silver.transferFrom(msg.sender, address(this), _amount);
            uint256 goldToSilver = ratioEthToGold * 1000 / ratioEthToSilver;
            Gold.transfer(
                msg.sender,
                _amount * goldToSilver / 1000
            );
        }

        emit TokenToEthAndTokenToTokenSwapped(_type, _amount);
    }

    /**
     * @dev External function to set token ratios. This function can be called by only owner.
     * @param _newRatioEthToGold New Eth to gold token ratio
     * @param _newRatioEthToSilver New Eth to silver token ratio
     */
    function changeTokenRatio(
        uint256 _newRatioEthToGold,
        uint256 _newRatioEthToSilver
    ) external onlyOwner {
        ratioEthToGold = _newRatioEthToGold;
        ratioEthToSilver = _newRatioEthToSilver;

        emit TokenRatioChanged(_newRatioEthToGold, _newRatioEthToSilver);
    }

    receive() external payable {}
}
