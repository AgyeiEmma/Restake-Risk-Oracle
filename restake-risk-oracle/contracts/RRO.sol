// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract RRO {
    // ========== STRUCTS ==========
    struct AVS {
        string name;
        uint8 baseRiskScore; // Risk score from 0 (safe) to 100 (high risk)
        bool exists;
    }

    struct UserPrefs {
        uint8 maxRiskScore; // Max acceptable risk score
        bool autoRebalance; // Future use
    }

    // ========== STATE VARIABLES ==========
    address public owner;

    mapping(address => UserPrefs) public userPreferences;
    mapping(address => mapping(string => uint256)) public userBalances; // mock user stake per AVS
    mapping(string => AVS) public avsRegistry;
    string[] public avsList;

    // ========== EVENTS ==========
    event AVSRegistered(string name, uint8 baseRiskScore);
    event RiskScoreUpdated(string avsName, uint8 newRiskScore);
    event UserPrefsUpdated(address user, uint8 maxRiskScore);
    event Rebalanced(address user, string fromAVS, string toAVS, uint256 amount);

    // ========== MODIFIERS ==========
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // ========== CONSTRUCTOR ==========
    constructor() {
        owner = msg.sender;
    }

    // ========== CORE FUNCTIONS ==========

    function registerAVS(string memory name, uint8 baseRiskScore) external onlyOwner {
        require(!avsRegistry[name].exists, "AVS already exists");
        require(baseRiskScore <= 100, "Invalid risk score");

        avsRegistry[name] = AVS(name, baseRiskScore, true);
        avsList.push(name);

        emit AVSRegistered(name, baseRiskScore);
    }

    function getRiskScore(string memory name) public view returns (uint8) {
        require(avsRegistry[name].exists, "AVS not found");
        return avsRegistry[name].baseRiskScore;
    }

    function updateRiskScore(string memory name, uint8 newRiskScore) external onlyOwner {
        require(avsRegistry[name].exists, "AVS not found");
        require(newRiskScore <= 100, "Invalid score");

        avsRegistry[name].baseRiskScore = newRiskScore;
        emit RiskScoreUpdated(name, newRiskScore);
    }

    function setUserPreferences(uint8 maxRiskScore) external {
        require(maxRiskScore <= 100, "Invalid threshold");
        userPreferences[msg.sender] = UserPrefs(maxRiskScore, true);
        emit UserPrefsUpdated(msg.sender, maxRiskScore);
    }

    // Mock function to deposit balance (simulating restaked tokens)
    function depositToAVS(string memory name, uint256 amount) external {
        require(avsRegistry[name].exists, "AVS not found");
        userBalances[msg.sender][name] += amount;
    }

    // Mock rebalance: shift from high-risk to first safe AVS
    function rebalance() external {
        UserPrefs memory prefs = userPreferences[msg.sender];

        for (uint i = 0; i < avsList.length; i++) {
            string memory avsName = avsList[i];
            uint8 score = avsRegistry[avsName].baseRiskScore;

            if (userBalances[msg.sender][avsName] > 0 && score > prefs.maxRiskScore) {
                // Rebalance to first safe AVS
                for (uint j = 0; j < avsList.length; j++) {
                    string memory saferAVS = avsList[j];
                    if (avsRegistry[saferAVS].baseRiskScore <= prefs.maxRiskScore) {
                        uint256 amount = userBalances[msg.sender][avsName];
                        userBalances[msg.sender][avsName] = 0;
                        userBalances[msg.sender][saferAVS] += amount;
                        emit Rebalanced(msg.sender, avsName, saferAVS, amount);
                        break;
                    }
                }
            }
        }
    }

    // ========== VIEW HELPERS ==========

    function getUserBalance(address user, string memory name) external view returns (uint256) {
        return userBalances[user][name];
    }

    function getAllAVSs() external view returns (string[] memory) {
        return avsList;
    }
}
