pragma solidity ^0.4.18;

import './crowdsale/Crowdsale.sol';
import './crowdsale/CappedCrowdsale.sol';

//pre ico crowdsale contract
contract MossCrowdsale is CappedCrowdsale {
    uint256[5][4] public bonus;
    uint256[5] public values; // bonus by send ether amount criteria
    uint256[4] public ends; // bonus by ico timing criteria

    function MossCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, uint256 _minInvestFinney, uint256 _maxInvestFinney, address _wallet, address _token) public
        CappedCrowdsale(_cap)
        Crowdsale(_startTime, _endTime, _rate, _minInvestFinney, _maxInvestFinney, _wallet, _token) 
    {
        values = [5 * 1 ether, 10 * 1 ether, 25 * 1 ether, 75 * 1 ether, _maxInvestFinney * 1 finney + 1];
    }

    function getTokens(uint256 _wei, uint256 _time) public view returns (uint256) {
        require(_time >= startTime && _time <= endTime);

        for (uint i = 0; i < values.length; ++i) {
            if (_wei >= values[i]) {
                continue;
            }

            for (uint j = 0; j < ends.length; ++j) {
                if (_time >= ends[j]) {
                    continue;
                }

                return _wei * rate * bonus[j][i] / 1000;
            }
        }

        assert(false);
    }
}

//main ico crowdsale contract
contract MossCrowdsalePre is MossCrowdsale {
    function MossCrowdsalePre(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, uint256 _minInvestFinney, uint256 _maxInvestFinney, address _wallet, address _token) public
        MossCrowdsale(_startTime, _endTime, _rate, _cap, _minInvestFinney, _maxInvestFinney, _wallet, _token)
    {
        ends = [_endTime + 1, _endTime + 1, _endTime + 1, _endTime + 1];
        bonus[0] = [1350, 1400, 1450, 1500, 1550];
    }
}

contract MossCrowdsaleMain is MossCrowdsale {
    function MossCrowdsaleMain(uint256 _startTime, uint256 _end1, uint256 _end2, uint256 _end3, uint256 _endTime, uint256 _rate, uint256 _capEther, uint256 _minInvestFinney, uint256 _maxInvestFinney, address _wallet, address _token) public
        MossCrowdsale(_startTime, _endTime, _rate, _capEther, _minInvestFinney, _maxInvestFinney, _wallet, _token)
    {
        ends = [_end1, _end2, _end3, _endTime + 1];
        bonus[0] = [1250, 1300, 1350, 1400, 1450];
        bonus[1] = [1150, 1200, 1250, 1350, 1400];
        bonus[2] = [1050, 1075, 1125, 1250, 1300];
        bonus[3] = [1025, 1025, 1050, 1100, 1200];
    }
}