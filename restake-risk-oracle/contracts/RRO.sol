// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract RRO {
    struct AVS {
        string name;
        uint8 baseRiskScore; // Risk score from 0 (safe) to 100 (high risk)
        bool exists;
    }

    struct UserPrefs {
        uint8 maxRiskScore; 
        bool autoRebalance; 
    }
 
    address public owner;
    address public trustedBackend;

    mapping(address => UserPrefs) public userPreferences;
    mapping(address => mapping(string => uint256)) public userBalances; // mock user stake per AVS
    mapping(string => AVS) public avsRegistry;
    string[] public avsList;

    event AVSRegistered(string name, uint8 baseRiskScore);
    event RiskScoreUpdated(string avsName, uint8 newRiskScore);
    event UserPrefsUpdated(address user, uint8 maxRiskScore);
    event Rebalanced(address user, string fromAVS, string toAVS, uint256 amount);
    event RebalanceTriggered(address user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyTrustedBackend() {
        require(msg.sender == trustedBackend, "Not authorized");
        _;
    }
    constructor(address backend) {
        owner = msg.sender;
        trustedBackend = backend;
    }

    function setTrustedBackend(address backend) external onlyOwner {
        trustedBackend = backend;
    }

    function registerAVS(string memory name, uint8 baseRiskScore) external onlyOwner {
        require(bytes(name).length > 0, "AVS name cannot be empty");
        require(bytes(name).length <= 32, "AVS name too long");
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

    function getAVSDetails(string memory name) external view returns (string memory avsName, uint8 baseRiskScore, bool exists) {
        require(avsRegistry[name].exists, "AVS not found");
        AVS memory avs = avsRegistry[name];
        return (avs.name, avs.baseRiskScore, avs.exists);
    }

    function updateRiskScore(string memory name, uint8 newRiskScore) external onlyOwner {
        require(avsRegistry[name].exists, "AVS not found");
        require(newRiskScore <= 100, "Invalid score");

        avsRegistry[name].baseRiskScore = newRiskScore;
        emit RiskScoreUpdated(name, newRiskScore);
    }

    function setUserPreferences(uint8 maxRiskScore) external {
        require(maxRiskScore <= 100, "Invalid threshold");
        require(maxRiskScore > 0, "Risk score must be greater than 0");

        userPreferences[msg.sender] = UserPrefs(maxRiskScore, true);
        emit UserPrefsUpdated(msg.sender, maxRiskScore);
    }

    function getUserPreferences(address user) external view returns (uint8 maxRiskScore, bool autoRebalance) {
        UserPrefs memory prefs = userPreferences[user];
        return (prefs.maxRiskScore, prefs.autoRebalance);
    }

    function depositToAVS(string memory name, uint256 amount) external {
        require(avsRegistry[name].exists, "AVS not found");
        userBalances[msg.sender][name] += amount;
    }

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

        emit RebalanceTriggered(msg.sender);
    }

    function triggerRebalance(address user) external onlyTrustedBackend {
    UserPrefs memory prefs = userPreferences[user];
    require(prefs.autoRebalance, "User has not opted into auto-rebalancing");

    for (uint i = 0; i < avsList.length; i++) {
        string memory avsName = avsList[i];
        uint8 score = avsRegistry[avsName].baseRiskScore;

        if (userBalances[user][avsName] > 0 && score > prefs.maxRiskScore) {
            for (uint j = 0; j < avsList.length; j++) {
                string memory saferAVS = avsList[j];
                if (avsRegistry[saferAVS].baseRiskScore <= prefs.maxRiskScore) {
                    uint256 amount = userBalances[user][avsName];
                    userBalances[user][avsName] = 0;
                    userBalances[user][saferAVS] += amount;
                    emit Rebalanced(user, avsName, saferAVS, amount);
                    break;
                }
            }
        }
    }

    emit RebalanceTriggered(user);
}

    function getUserBalance(address user, string memory name) external view returns (uint256) {
        return userBalances[user][name];
    }

    function getAllAVSs() external view returns (string[] memory) {
        return avsList;
    }

    // Chainlink variables
    AggregatorV3Interface public riskScoreOracle;

    // Function to set the Chainlink oracle address
    function setRiskScoreOracle(address oracle) external onlyOwner {
        riskScoreOracle = AggregatorV3Interface(oracle);
    }

    // Function to fetch the latest risk score from the oracle
    function fetchRiskScoreFromOracle(string memory avsName) public view returns (uint8) {
        require(avsRegistry[avsName].exists, "AVS not found");

        // Fetch the latest data from the oracle
        (, int256 riskScore, , , ) = riskScoreOracle.latestRoundData();

        // Ensure the risk score is within the valid range for uint8
        require(riskScore >= 0 && riskScore <= 255, "Invalid risk score from oracle");

        // Convert int256 to uint256, then to uint8
        return uint8(uint256(riskScore));
    }

    // Update the `updateRiskScoreFromOracle` function
    function updateRiskScoreFromOracle(string memory avsName) external onlyTrustedBackend {
        require(avsRegistry[avsName].exists, "AVS not found");

        // Fetch the latest risk score from the oracle
        uint8 newRiskScore = fetchRiskScoreFromOracle(avsName);

        // Update the AVS risk score
        avsRegistry[avsName].baseRiskScore = newRiskScore;
        emit RiskScoreUpdated(avsName, newRiskScore);
    }
}
