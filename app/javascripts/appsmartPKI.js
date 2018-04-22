// Import the page's CSS. Webpack will know what to do with it.
// Import libraries we need.
const Web3 = require('web3');
const contract = require('truffle-contract');

// Import our contract artifacts and turn them into usable abstractions.
const smartPKI_artifacts = require('../../build/contracts/ApplicationPolicyPublisher.json');

// Usable abstraction, which we'll use through the code below.
var ApplicationPolicyPublisher = contract(smartPKI_artifacts);
var account;
var accounts;
let web3Provided;
//var usrObj = Object.create(App);
// call functions
//setWeb3Provider();
//console.log(web3Provided);
//console.log("account");

//sendCertRequest("testname",1,2);


// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.

var App = {
   startWork: function() {
    var self = this;
    // Bootstrap the MetaCoin abstraction for Use.
    ApplicationPolicyPublisher.setProvider(web3Provided.currentProvider);
    web3Provided.eth.getAccounts(function(err, accs){
    	if(err !=null){
		console.log(" Fetching account error");
		return;
	}
    	if (accs.length == 0){
		console.log("Couldnot get any accounts");
		return;
	}

	accounts = accs;
	account = accounts[0];
	console.log("Caller Account Address:", account);
	console.log("ABI link: ", process.argv[2]);
	console.log("Contract Address: ", process.argv[3])
	console.log("Policy Contract Id: ",process.argv[4])
	console.log("Trust State:")

    self.verifyCAtoCertOwnerPolicyContract(process.argv[4])

    });
},

  publishApplicationPolicy: function(index) {
    var self = this;

    TransparentContractCA.deployed().then(function(instance) {
      return instance.verifyCAtoCertOwnerPolicyContract.call(index, {from: account});
    }).then(function(value) {
      console.log(value);
    }).catch(function(e) {
      console.log(e);
      console.log("Error getting getCertChallenge; see log.");
    });
},

 sendCertRequest: function(certCsr, certNotBefore, certNotAfter) {
    var self = this;
    console.log("Initiating transaction... (please wait)");
    SmartPKI.deployed().then(function(instance) {
      return instance.addCertRequest(certCsr, certNotBefore, certNotAfter, {from: account, gas:400000} );
    }).then(function(value) {
      console.log("Transaction complete!");
      console.log(value);
    }).catch(function(e) {
      console.log(e);
      console.log("Error sending cert request; see log.");
    });
}
};

var usrObj = Object.create(App);
// call functions
setWeb3Provider();
// console.log(web3Provided);
// console.log("account");
//

function setWeb3Provider() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. ");
    // Use Mist/MetaMask's provider
    web3Provided = new Web3(web3.currentProvider);
  } else {
    //console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    web3Provided = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  usrObj.startWork();
}
