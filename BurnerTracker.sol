contract BurnerTracker {
    struct Burn {
        address burner;
        uint256 value;
        uint256 timestamp;
    }

    Burn[] public burners; // Array to store all burn records
    Burn[] private latestBurns; // Array to store latest burn records

    mapping(address => Burn) public addressBurnInfo; // Mapping to store burner info by address
    mapping(address => Burn[]) private addressBurnHistory; // Mapping to store burn history for each address
    mapping(address => bool) private hasAddressBurnt; // Mapping to track whether an address has burned
    mapping(address => uint256) public addressTotalBurnValue; // Mapping to store total burn value by address

    // Function to record a burn
    function recordBurn(uint256 value) internal virtual {
        Burn memory newBurn = Burn(msg.sender, value, block.timestamp);

        if(hasAddressBurnt[msg.sender]){
            for (uint256 i; i < burners.length; i++) 
            {
                if(msg.sender == burners[i].burner) {
                    burners[i].value +=  value;
                    burners[i].timestamp = block.timestamp;
                }
            }
        } else {
            burners.push(newBurn);
            hasAddressBurnt[msg.sender] = true;
        }
        
        // Update burn history for the burner
        addressBurnHistory[msg.sender].push(newBurn);

        // Update total burn value for the burner
        uint256 vlt = addressTotalBurnValue[msg.sender] + value;
        addressTotalBurnValue[msg.sender] += value;
        addressBurnInfo[msg.sender] = Burn(msg.sender, vlt, block.timestamp);

        // Update latest burn record
        latestBurns.push(newBurn);
    }

    // Function to get the number of recorded burns, no double address counting
    function getBurnersCount() public view returns (uint256) {
        return burners.length;
    }

    // Function to get the latest burn record
    function getRecentBurn() public view returns (Burn memory) {
        require(latestBurns.length > 0, "No burns recorded");
        return latestBurns[latestBurns.length - 1];
    }

    // Function to get all burners
    function getAllBurners() public view returns (address[] memory burnerAddr, uint256[] memory burntValue, uint256[] memory LastestTimestamp) {
        uint256 length = burners.length;
        address[] memory burnerAddresses = new address[](length);
        uint256[] memory burnerValues = new uint256[](length);
        uint256[] memory timestamp = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            burnerAddresses[i] = burners[i].burner;
            burnerValues[i] = addressTotalBurnValue[burners[i].burner];
            timestamp[i] = burners[i].timestamp;
        }

        return (burnerAddresses, burnerValues, timestamp);
    }

    // Function to get the burn history of a specific address
    function getBurnHistory(address _address) public view returns (Burn[] memory) {
        return addressBurnHistory[_address];
    }
}