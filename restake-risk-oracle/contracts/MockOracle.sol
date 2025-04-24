// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockOracle {
    int256 public latestRiskScore;

    constructor(int256 initialRiskScore) {
        latestRiskScore = initialRiskScore;
    }

    function setRiskScore(int256 newRiskScore) external {
        latestRiskScore = newRiskScore;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, latestRiskScore, block.timestamp, block.timestamp, 0);
    }
}