pragma solidity ^0.4.2;
// CertOwnerContract defined by any Owner of the certificate , which
// also takes responsibility to of cert owners conditions

contract TransparentContractCA{

    // CertOwner (Domain Owner)
    struct CertOwnerPolicy{
        address owner;  //owner of the contract creator or owner of the policy
        string certOwnerId;
        string certOwnerPolicyId;
        string certOwnerPolicyLink; // It could be hash to the policy file
    }

    struct CertPolicyContractRequestToCa{
         uint certPolicyContractRequestToCaId;
         string certOwnerPolicyId;
         string caId; //address of the CA, where a CA is listening
    }

    CertOwnerPolicy[] public certOwnerPolicies;
    CertPolicyContractRequestToCa[] public certPolicyContractRequestToCas;

     // called by the domain owner. Certowner policy defines the requested
     // restriction of the certificate and application it should support
     // Certowner
    function addCertOwnerPolicy(string certOwnerId, string certPolicyId,
        string certPolicyLink) returns (uint){
        certOwnerPolicies.length++;
        certOwnerPolicies[certOwnerPolicies.length-1].owner = msg.sender;
        certOwnerPolicies[certOwnerPolicies.length-1].certOwnerId = certOwnerId;
        certOwnerPolicies[certOwnerPolicies.length-1].certOwnerPolicyId = certPolicyId;
        certOwnerPolicies[certOwnerPolicies.length-1].certOwnerPolicyLink = certPolicyLink;
        return certOwnerPolicies.length-1;
        //return 1;
    }

    // Executed by Domain owner to make a contract with a CA
        // This starts the policy contract process between a CA and a Domain owner.
        // The actual contract is made by CA later step.
        // This is executed before making a certificate issuance request
        // The certpolicycontractrequesttocaid can be searched by CA or can be sent offline by DO to CA.
        function addCertPolicyContractRequestToCa(string certOwnerPolicyId, string caId) returns (uint){
                certPolicyContractRequestToCas.length++;
                //TODO:- before adding check applicationPolicyId really exist
                certPolicyContractRequestToCas[certPolicyContractRequestToCas.length-1].certPolicyContractRequestToCaId = certPolicyContractRequestToCas.length-1;
                certPolicyContractRequestToCas[certPolicyContractRequestToCas.length-1].certOwnerPolicyId = certOwnerPolicyId;
                certPolicyContractRequestToCas[certPolicyContractRequestToCas.length-1].caId = caId;
                return certPolicyContractRequestToCas.length-1;
         }


    //// Application related contracts info
    struct ApplicationPolicy{
        address owner;  //Owner of the policy
        string applicationId;
        string applicationPolicyId;
        string applicationPolicyLink; // it could be hash to the policy file
        string CAid; //id of the CA
        string isValid;
    }

    ApplicationPolicy[] public applicationPolicies;

    // application owner makes a policy
    function addApplicationPolicy(string applicationId, string policyId, string policyLink, string CAid) returns (uint){
        applicationPolicies.length++;
        applicationPolicies[applicationPolicies.length-1].owner = msg.sender;
        applicationPolicies[applicationPolicies.length-1].applicationId = applicationId;
        applicationPolicies[applicationPolicies.length-1].applicationPolicyId = policyId;
        applicationPolicies[applicationPolicies.length-1].applicationPolicyLink = policyLink;
        applicationPolicies[applicationPolicies.length-1].CAid = CAid;
        applicationPolicies[applicationPolicies.length-1].isValid = 'True';
        //notifyCaAboutPolicy((applicationPolicies.length-1)); // notify CA that an application has trusted/changed policy for you you
        return applicationPolicies.length-1;
    }

    function modifyExistingAppPolicy(string applicationCaPolicyId, string validity) returns (uint){
        //find existing application policy with the application id
          // set validity period for the existing application policy
          // any policy provider should be able to modify the contract)
        // Notify via event to the CA for any policy change
          // Each CA should filter any request arriving
          // for their policy with a reason code
          // Based on this CA take action ( out side contract)

    }

    // index will define a specific policy (in future we use applicationPolicyId
    // which is published, for finding the link
    function getApplicationPolicy(uint index) public constant returns (string, string, string){
        if(index == 0) return ("null","null", "null");
        else{
            return (applicationPolicies[index].applicationPolicyId,
                applicationPolicies[index].applicationPolicyLink, applicationPolicies[index].CAid);
        }
    }

    // Notify CA regarding policy changes/modification executed by the ApplicationPolicyOwner
    function notifyCaAboutPolicy(string applicationPolicyId){
        //check caller is the owner of applicationPolicyId
        string memory applicationPolicyIdMirror;
        string memory applicationPolicyLink;
        string memory caId;
        //(applicationPolicyIdMirror, applicationPolicyLink, caId) = getApplicationPolicy(applicationPolicyId);
        //TODO:- Check if the return types are correct
        //notify() to CAid
    }


    //// CA related Contracts are here
    struct CAPolicy{
        address owner;  //owner of the contract creator or owner of the policy
        string caId;
        string caPolicyId;
        string caPolicyLink; // in future it could be hash to the policy file
        string applicationPolicyIds;
        string penalty;
        string isValid;
    }

    struct CAtoCertOwnerPolicyContract{
            address owner;
            uint cAtoCertOwnerPolicyContractId;
            string certPolicyContractRequestToCaId;
            string certOwnerPolicyId;
            string applicationPolicyId;
            string caPolicyId;
            string isValid;
        }


    CAPolicy[] public caPolicies;
    CAtoCertOwnerPolicyContract[] public cAtoCertOwnerPolicyContracts;

    // This adds CA policies. It contains trust anchor to a CA
    function addCAPolicy(string caId, string caPolicyId, string caPolicyLink, string applicationPolicyIds, string penalty) returns (uint){
        caPolicies.length++;
        caPolicies[caPolicies.length-1].owner = msg.sender;
        caPolicies[caPolicies.length-1].caId = caId;
        caPolicies[caPolicies.length-1].caPolicyId = caPolicyId;
        caPolicies[caPolicies.length-1].caPolicyLink = caPolicyLink;
        //validateApplicationPolicy(applicationPolicyId,caPolicyId); // application policy can only be added if
        // relevant application policy exists.
        // TODO: - Add application policy only later on, only after checking.
        caPolicies[caPolicies.length-1].applicationPolicyIds = applicationPolicyIds;
        caPolicies[caPolicies.length-1].penalty = penalty;
        caPolicies[caPolicies.length-1].isValid = 'True';
        return caPolicies.length-1;
        //return 1;
    }

     event PolicyNumberEvent(uint index, bool retValue);

    // subscribe to application policy with cert owner policy executed by the cert owner
    // optinally certPolicyContractRequestToCaId can be replaced with domainPolicy ( this doesn not provide evidence
    // than a certificate is actually requested by a domain owner.
     function addCAtoCertOwnerPolicyContract(string certPolicyContractRequestToCaId,
           string certOwnerPolicyId, string applicationPolicyId, string caPolicyId) returns (uint){
            cAtoCertOwnerPolicyContracts.length++;
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].owner = msg.sender;
            //TODO:- before adding check applicationPolicyId exits in the CA_policy
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].cAtoCertOwnerPolicyContractId = cAtoCertOwnerPolicyContracts.length-1;
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].certPolicyContractRequestToCaId =  certPolicyContractRequestToCaId;
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].certOwnerPolicyId = certOwnerPolicyId;
            //validateCaPolicyId(caPolicyId); // validate policy before use
            //should we add a link to the contract including more expressive policy e.g.,
            // trusted browsers , other conditions in the policyContract or it is enough
            // that there two policy (CA and domain policy is linked)
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].applicationPolicyId = applicationPolicyId;
            // applicationPolicyId is added to test directly, not needed in real case
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].caPolicyId = caPolicyId;
            cAtoCertOwnerPolicyContracts[cAtoCertOwnerPolicyContracts.length-1].isValid = 'True';
            //TODO:- subscribe to CA policy id  and domain policy address (contract address)
            // if domain requirement can not be me, set validity false
            //TODO:- if a notification comes from CApolicyId or domain Policy ID,
            // TODO: notifyCertOwner(certOwnerPolicyId); // notify domain owner that contract change.
            // domian contract listening is external to the contract (as when domain contract created,
            // it does not know about policy contract. So this is optional. We assume owners monitor
            // the policy contract for this directly
            PolicyNumberEvent(cAtoCertOwnerPolicyContracts.length, true);
            return cAtoCertOwnerPolicyContracts.length-1;
     }

// Verify current trust state of the policyContract
// can be executed by anyone
     function verifyCAtoCertOwnerPolicyContract(uint index) public constant returns (string, string, string, string){
            if(index == 0) return ("null","null", "null", "null");
            else{ return (
            cAtoCertOwnerPolicyContracts[index].certPolicyContractRequestToCaId,
            cAtoCertOwnerPolicyContracts[index].certOwnerPolicyId,
            cAtoCertOwnerPolicyContracts[index].caPolicyId,
            cAtoCertOwnerPolicyContracts[index].applicationPolicyId);
            }
     }

}
