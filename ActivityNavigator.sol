pragma solidity ^0.4.19;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract ActivityNavigator is usingOraclize {
    bool public accepted;
    
    event getActivityResult(bool confirm);
    event newOraclizeQuery(string description);

    function Navigator() {// payable {
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress())
            throw;
            
        accepted = compareStrings(result, "true");
        getActivityResult(accepted);
    }

    // task uid
    function update(string taskId) payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "json(http://technobee.elementstore.ru/api/Activity/1).confirm");
    }
    
    function compareStrings (string a, string b) view returns (bool){
       return keccak256(a) == keccak256(b);
    }
}
