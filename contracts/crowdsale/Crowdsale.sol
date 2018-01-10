pragma solidity ^0.4.18;

import '../math/SafeMath.sol';
import '../token/CrowdsaleToken.sol';

contract Crowdsale {
    using SafeMath for uint256;

    mapping(address => uint256) balanceOf;

    CrowdsaleToken public token;

    uint256 public startTime;
    uint256 public endTime;

    address public wallet;

    uint256 public rate;
    
    uint256 public weiRaised;

    uint256 public maxInvest;
    uint256 public minInvest;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _minInvest, uint256 _maxInvest, address _wallet, address _token) public {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != address(0));

        token = CrowdsaleToken(_token);
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
        minInvest = _minInvest * 1 finney;
        maxInvest = _maxInvest * 1 finney;
    }

    function() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase(beneficiary));

        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(rate);

        weiRaised = weiRaised.add(weiAmount);
        balanceOf[beneficiary] = balanceOf[beneficiary].add(weiAmount);

        token.sale(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    function validPurchase(address beneficiary) internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool validCondition = beneficiary != 0x0 && msg.value >= minInvest && balanceOf[beneficiary] + msg.value <= maxInvest;
        return withinPeriod && validCondition;
    }

    function hasEnded() public view returns (bool) {
        return now > endTime;
    }
}