pragma solidity ^0.4.19;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract ActivityNavigator is usingOraclize {
    string public accepted;
    
    event getActivityResult(string  confirm);
    event newOraclizeQuery(string description);

    function Navigator() {// payable {
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress())
            throw;
            
        accepted = result;
        getActivityResult(result);
    }

    // task uid
    function update(string taskId) payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "json(http://technobee.elementstore.ru/api/Activity/1).confirm");
    }
}
