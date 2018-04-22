// Policy aware Smart contract enabled Public key infrastructure
// A contract among CA, Domain owner and application provider (e.g., Browser).
// Policy contract is executed by CA after receiving request from domain owner
// Policy contract makes a contract between application (trust) policy and CA.
// Procedure:
// 1. A CA monitors ( event log) published application trust policies by
//    application provider for a CA
// 2. When a request arrives from domain owner to a CA for contract, it
//    invokes the policy contract
// 3. Policy Contract subscribes to valid application trust polices for
//    that CA
// 4. When application later on decides to change application trust
//    policies, it notifies the contract
// 5. This way the trust relationship between policyContract and
//    application trust policies is always dynamic.
// 6. The domain owner can always verify the policyContract and application
//    trust policy by checking at the contract

pragma solidity ^0.4.2;

contract PolicyContract{

    event event_policyContractComplete( uint id, address applicationPolicyAddr, uint applicationPolicyId, bytes32 validity, string s);
    event event_ChangePolicyContract(string s, address from, bytes32 validity);

    address public owner;
    struct CAtoDomainOwnerPolicyContract{
          bytes32 domainToCaPolicyContractRequestId; //request id from domain
          uint applicationPolicyId;
          bytes32 caId;
          bytes32 validity; //limitation 32 byte only
          address applicationPolicyAddress;
    }

    mapping (uint => CAtoDomainOwnerPolicyContract) CAtoDomainOwnerPolicyContracts;

    function policyContract(){
         owner = msg.sender;
    }

    // CA publish the policyContract after getting a request from a domain
    function publishCAtoDomainPolicyContract(uint id, string applicationPolicyAddress, uint applicationPolicyId,
                 bytes32 domainToCaPolicyContractRequestId) returns (uint){

          //if(msg.sender != owner) return;

          bytes32 caId;
          bytes32 validity;
          address applicationPolicyAddr = parseAddr(applicationPolicyAddress);

          // Check application policy exists
          ApplicationPolicyPublisher applicationPolicyPublisher = ApplicationPolicyPublisher(applicationPolicyAddr);
          (caId, validity) = applicationPolicyPublisher.getApplicationPolicyStatus(applicationPolicyId);
          if (caId.length == 0) return ;

          //subscribe to application policy. Provide information about policyContract, so application policy can
          //call it later on
          applicationPolicyPublisher.subscribeApplicationPolicy(id, applicationPolicyId, address(this), "public key");

          CAtoDomainOwnerPolicyContracts[id].domainToCaPolicyContractRequestId = domainToCaPolicyContractRequestId;
          CAtoDomainOwnerPolicyContracts[id].applicationPolicyId = applicationPolicyId;
          CAtoDomainOwnerPolicyContracts[id].caId = caId;
          CAtoDomainOwnerPolicyContracts[id].validity = validity;
          CAtoDomainOwnerPolicyContracts[id].applicationPolicyAddress = applicationPolicyAddr;

          event_policyContractComplete( id, applicationPolicyAddr, applicationPolicyId, validity, "contract completed");
     }

    // Called by application provider when application policy change
    function changeValue(address from, uint policyContractId, bytes32 validity) {

          //TODO:- Check a valid policyContractId exists
          CAtoDomainOwnerPolicyContracts[policyContractId].validity = validity;
          event_ChangePolicyContract("App Policy Changed", from, validity);
     }

    // executed by any party e.g., domain owner to check current status of the contract
    function verifyPolicyContract(uint index) public constant returns (string, address, uint, string){
            return (
            bytes32ToString(CAtoDomainOwnerPolicyContracts[index].domainToCaPolicyContractRequestId),
            CAtoDomainOwnerPolicyContracts[index].applicationPolicyAddress,
            CAtoDomainOwnerPolicyContracts[index].applicationPolicyId,
            bytes32ToString(CAtoDomainOwnerPolicyContracts[index].validity));
     }

    function bytes32ToString(bytes32 x) constant returns (string) {
            bytes memory bytesString = new bytes(32);
            uint charCount = 0;
            for (uint j = 0; j < 32; j++) {
                byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[charCount] = char;
                    charCount++;
                }
            }
            bytes memory bytesStringTrimmed = new bytes(charCount);
            for (j = 0; j < charCount; j++) {
                bytesStringTrimmed[j] = bytesString[j];
            }
            return string(bytesStringTrimmed);
    }

    function parseAddr(string _a) internal returns (address){
            bytes memory tmp = bytes(_a);
            uint160 iaddr = 0;
            uint160 b1;
            uint160 b2;
            for (uint i=2; i<2+2*20; i+=2){
                iaddr *= 256;
                b1 = uint160(tmp[i]);
                b2 = uint160(tmp[i+1]);
                if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
                else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
                if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
                else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
                iaddr += (b1*16+b2);
            }
            return address(iaddr);
    }
}


// Application trust policy contract
// This is executed by Application provider

contract ApplicationPolicyPublisher {

    event event_publishApplicationPolicy(uint id, string applicationPolicyLink, bytes32 caId, bytes32 validity);
    event event_notSubscribed(uint id, address c, bytes pbkey, string s);
    event event_subscribed(uint policyContractId, uint applicationPolicyId, address c, bytes pbkey);
    event event_ModifyApplicationPolicy(uint id, uint policyContractId, bytes32 validity);

    struct applicationPolicy {
            string applicationPolicyLink; // it could be hash to the policy file
            string notification;
            bytes32 caId;
            bytes32 validity; // True, false or notification
    }

    struct requestor {
            uint policyContractId;
            uint applicationPolicyId;
            address requestContract; //address of PolicyContract
            bytes pbkey; //public key of the PolicyContract creator
    }

    address public owner;
    uint[] ids;
    mapping (uint => applicationPolicy) applicationPolicies;
    requestor[] requestors;
    uint head;

    //publish trust policy of an application(browser) for a CA
    function publishApplicationPolicy(uint id, string applicationPolicyLink, bytes32 caId, bytes32 validity) {
            //if(msg.sender != owner) return;

            ids.length +=1;
            ids[ids.length-1] = id;
            applicationPolicies[id].applicationPolicyLink = applicationPolicyLink;
            applicationPolicies[id].caId = caId;
            applicationPolicies[id].validity = validity;
            event_publishApplicationPolicy(id, applicationPolicyLink, caId, validity);
    }

    // Get application policy for a particular id
    // Called by domain owner - or others
    function getApplicationPolicy(uint id) public constant returns (string, string, string, string){
            if (applicationPolicies[id].caId.length == 0) return;
            return (applicationPolicies[id].applicationPolicyLink, applicationPolicies[id].notification,
                 bytes32ToString(applicationPolicies[id].caId), bytes32ToString(applicationPolicies[id].validity));
    }

    // called by policy contract to get application policy status
    function getApplicationPolicyStatus(uint id) public constant returns(bytes32, bytes32){
             if (applicationPolicies[id].caId.length == 0) return;
                  return (applicationPolicies[id].caId, applicationPolicies[id].validity);
    }


    function applicationPolicyPublisher(uint size){
            owner = msg.sender;
            requestors.length = size;
    }

    // PolicyContract subscribe to application trust policy
    function subscribeApplicationPolicy(uint policyContractId, uint applicationPolicyId, address c, bytes pbkey) {
            if (applicationPolicies[applicationPolicyId].caId.length == 0){
            event_notSubscribed(applicationPolicyId, c, pbkey, "Application policy not found");
            }

            //add to the requestor queue
            requestors.length++;
            requestors[head].policyContractId = policyContractId;
            requestors[head].applicationPolicyId = applicationPolicyId;
            requestors[head].requestContract = c;
            requestors[head].pbkey = pbkey;

            head = head + 1;
            event_subscribed(policyContractId, applicationPolicyId, c, pbkey);
    }

    // When application provider changes a policy, notification is sent to the subscribed policyContract
    function modifyApplicationPolicy(uint id, bytes32 validity, string notification) {
            //if (msg.sender != owner) return;

            // no policy found with the provided id
            if (applicationPolicies[id].caId.length == 0) return;

            applicationPolicies[id].validity = validity;
            applicationPolicies[id].notification = notification;

            for (uint i =0; i < requestors.length; i++){
                if (requestors[i].applicationPolicyId == id) {
                     (PolicyContract(requestors[i].requestContract)).changeValue(owner, requestors[i].policyContractId, validity);
                     event_ModifyApplicationPolicy(id, requestors[i].policyContractId, validity);
                }
            }
    }

    function stringToBytes32(string memory source) returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}


