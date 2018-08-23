pragma solidity ^0.4.19;
//import "github.com/IgorGutsaev/SmartContracts/ActivityNavigator.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Escrow is usingOraclize {
    
   // address watch_addr = 0x6fdfddf3f98a15531dd47929c92be42693e0d852;
    
    uint balance;
    address public retailer;
    address public customer;
    address private escrow;
    uint private start;
    bool retailerOk;
    bool customerOk;
    
 //   event test_value(string log);
    
    function getBalance() constant public returns( uint ) {
        return balance;
    }
    
    function isRetailerOk() constant public returns( bool ) {
        return retailerOk;
    }
    
    function isCustomerOk() constant public returns( bool ) {
        return customerOk;
    }
    
    function Escrow(address retailer_address, address customer_address) public {
        // this is the constructor function that runs ONCE upon initialization
        retailer = retailer_address;
        customer = customer_address;
        escrow = msg.sender;
        start = now; //now is an alias for block.timestamp, not really "now"
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress())
            throw;
            
        if (compareStrings(result, "true")) {
            retailerOk = true;
             
            if (customerOk) {
                payBalance();
            } else if (!customerOk && now > start + 7 days) {
                // Freeze 7 days before release to retailer. The customer has to remember to call this method after freeze period.
                selfdestruct(retailer);
            }
        }
    }
    
    function acceptRetailer() public payable {
        if (msg.sender == retailer) {
          oraclize_query("URL", "json(http://technobee.elementstore.ru/api/Activity/1).confirm");
        }
    }
    
     function acceptCustomer() public {
        if (msg.sender == customer) {
            customerOk = true;
        }
        
        if (retailerOk && customerOk) {
            payBalance();
        } else if (retailerOk && !customerOk && now > start + 7 days) {
            // Freeze 7 days before release to retailer. The customer has to remember to call this method after freeze period.
            selfdestruct(retailer);
        }
    }
    
    function payBalance() private {
        // we are sending ourselves (contract creator) a fee
        escrow.transfer(this.balance / 100);
        // send customer the balance
        if (customer.send(this.balance)) {
            balance = 0;
        } else {
            throw;
        }
    }
    
    function deposit() public payable {
        if (msg.sender == retailer) {
            balance += msg.value;
        }
    }
    
    function cancel() public {
        if (msg.sender == retailer){
            retailerOk = false;
        } else if (msg.sender == customer){
            customerOk = false;
        }
        // if both retailer and customer would like to cancel, money is returned to retailer 
        if (!retailerOk && !customerOk){
            selfdestruct(retailer);
        }
    }
    
    function kill() public constant {
        if (msg.sender == escrow) {
            selfdestruct(retailer);
        }
    }
    
        function compareStrings (string a, string b) private view returns (bool){
       return keccak256(a) == keccak256(b);
    }
}
