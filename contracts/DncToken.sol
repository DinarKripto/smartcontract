pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

contract DncToken is ERC20, ERC20Detailed , ERC20Pausable, ERC20Capped , ERC20Burnable, Ownable , ReentrancyGuard {

    constructor(string _name, string _symbol, uint8 _decimals, uint256 _cap) 
        ERC20Detailed(_name, _symbol, _decimals)
        ERC20Capped (_cap * 1 ether)
        public {
    }

    uint256 public _rate= 67;

    uint256 private _weiRaised;

    address private _wallet = 0x8EbCE038Dc6851655e230A6D2d088c70d584A92A;

    event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
    );

    function () external payable {
        buyTokens(msg.sender);
    }

    function ChangeRate(uint256 newRate) public onlyOwner whenNotPaused{
        _rate = newRate;
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return (weiAmount.mul(_rate)).div(100);
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _preValidatePurchase(beneficiary, weiAmount);
        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );

    //_updatePurchasingState(beneficiary, weiAmount);
        _forwardFunds();
   // _postValidatePurchase(beneficiary, weiAmount);
    }

    function _preValidatePurchase (
        address beneficiary,
        uint256 weiAmount
    )
    internal
    view
    {
        require(beneficiary != address(0));
        require(weiAmount != 0);
    }

    function _processPurchase(
        address beneficiary,
        uint256 tokenAmount
    )
    internal
    {
        _deliverTokens(beneficiary, tokenAmount);
    }

    function _deliverTokens (
        address beneficiary,
        uint256 tokenAmount
    )
    internal
    {
        Mint(beneficiary, tokenAmount);
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}

