pragma solidity ^0.4.2;

// Smart contract for RA system (look alike ACME systems).

contract SmartPKI{

	//Based on ACME new-order request. 
	struct CertRequest {
		address owner;
		string certCsr;
		uint certNotBefore;  //days
		uint certNotAfter;  //days
	}

	struct CertChallenge{
		address owner;
		string status;
		uint expires; //days
		string authorizations;  //consider one only
	}

    CertRequest[] public certRequests;
	CertChallenge[] public certChallenges;

	function addCertRequest(string certCsr, uint certNotBefore,
			       	uint certNotAfter) returns (uint){
		certRequests.length++;
		certRequests[certRequests.length-1].owner = msg.sender;
		certRequests[certRequests.length-1].certCsr = certCsr;
		certRequests[certRequests.length-1].certNotBefore = certNotBefore;
		certRequests[certRequests.length-1].certNotAfter = certNotAfter;
        return processCertRequest(certRequests.length-1);
        //return 1;    
		
	}

        // CA process requests
	function processCertRequest(uint index) returns (uint){
	       if (uniqueName(certRequests[index].certCsr)){
            certChallenges.length++;
			certChallenges[certChallenges.length-1].owner = msg.sender;
			certChallenges[certChallenges.length-1].status = "pending";
		        certChallenges[certChallenges.length-1].expires = 1 days;
			certChallenges[certChallenges.length-1].authorizations = 
				"https://testserver.com/authz/1234";
			return certChallenges.length-1; 	

	       }else{
		      return 0;
	       } 
	}

       function uniqueName(string csr) returns (bool){
	       return true;
       }

       function getCertChallenge(uint index) public constant returns (string,
uint, string){
	       if(index == 0) return ("null",0,"null");
	       else{
       		return (certChallenges[index].status,
               certChallenges[index].expires,
               certChallenges[index].authorizations);
	       }
       }
}

// Verify challenges
// Sign certificate return
// Audit
