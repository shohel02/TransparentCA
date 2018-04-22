// Import the page's CSS. Webpack will know what to do with it.
// Import libraries we need.
const Web3 = require('web3');
const contract = require('truffle-contract');

// Import our contract artifacts and turn them into usable abstractions.
const smartPKI_artifacts = require('../../build/contracts/ApplicationPolicyPublisher.json');
const PolicyContract_artifacts = require('../../build/contracts/PolicyContract.json');
// Usable abstraction, which we'll use through the code below.
var ApplicationPolicyPublisher = contract(smartPKI_artifacts);
var PolicyContract = contract(PolicyContract_artifacts);
var account;
var accounts;
let web3Provided;


// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.

var App = {
   startWork: function() {
    var self = this;
    // Bootstrap the MetaCoin abstraction for Use.
    ApplicationPolicyPublisher.setProvider(web3Provided.currentProvider);
    PolicyContract.setProvider(web3Provided.currentProvider);
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
    //self.publishApplicationPolicy(1, '{\"PolicyId\": \"EV Server Authentication (1.3.6.1.4.1.311.94.1.1)\", \"Policies\": { \"applications\": [ {\"app\": { \"name\": \"Chrome\", \"status\": \"Full\"}}, {\"app\": { \"name\": \"Apple\", \"status\": \"Marginal\"}}, {\"app\": { \"name\": \"Android\", \"status\": \"Unknown\"}}, {\"app\": { \"name\": \"Mozilla\", \"status\": \"Full\", \"notice\": \"Not After Jan 2019\"} }] } }' , "Sym-level2-cert", "NOT AFTER 1-30-2019");

	for(i=0; i<200; i++){
      //self.publishCAtoDomainPolicyContract(i,"0x1ca8b565579c6328fd8a09189d3f2a5730e00557", 1, "domianRequest-1");
    }
    });

     //self.modifyApplicationPolicy(1,"true", "Policy Contract Invalid After JAN 2019");
     //self.getApplicationPolicy(1);
     //console.log("Caller Account Address:", account);
     console.log('RESULT:');
     console.log("ABI link: ", process.argv[2]);
     console.log("Contract Address: ", process.argv[3])
     console.log("Policy Contract Id: ",process.argv[4])
     self.verifyPolicyContract(process.argv[4]);
},

  publishCAtoDomainPolicyContract: function(index,addressId,appId,requestId) {
    var self = this;
    console.log("Initiating Transaction");
    PolicyContract.deployed().then(function(instance) {
      return instance.publishCAtoDomainPolicyContract(parseInt(index), addressId, parseInt(appId), requestId, {from: account, gas:4000000});
    }).then(function(value) {
      console.log("Transaction complete");
      console.log(value);
    }).catch(function(e) {
      console.log(e);
      console.log("Error publishing policy; see log.");
    });
  },


  verifyPolicyContract: function(index) {
    var self = this;
    console.log("Verify Policy Contract for Index ", index);
    PolicyContract.deployed().then(function(instance) {
      return instance.verifyPolicyContract(parseInt(index),{from: account, gas:4000000});
    }).then(function(value) {
      //console.log("Verification complete for Policy Contract Id: ",index);
      console.log("Domain Request Id: ",value[0]);
      console.log("ApplicationPolicy Address: ", value[1]);
      console.log("ApplicationPolicy Id: ",parseInt(value[2]));
      console.log("Contract Validity Status: ", value[3]);
      self.getApplicationPolicy(parseInt(value[2]));
    }).catch(function(e) {
      console.log(e);
      console.log("Error; see log.");
    });
  },

  publishApplicationPolicy: function(index,policy,caId,validity) {
    var self = this;
    console.log("Initiating Transaction");
    ApplicationPolicyPublisher.deployed().then(function(instance) {
      return instance.publishApplicationPolicy(parseInt(index), policy, caId, validity, {from: account, gas:4000000});
    }).then(function(value) {
      console.log("Transaction complete");
      console.log(value);
    }).catch(function(e) {
      console.log(e);
      console.log("Error publishing policy; see log.");
    });
  },

  modifyApplicationPolicy: function(index, validity, notification) {
      var self = this;
      console.log("Initiating Transaction Modify policy");
      ApplicationPolicyPublisher.deployed().then(function(instance) {
        return instance.modifyApplicationPolicy(parseInt(index), validity, notification, {from: account, gas:4700000});
      }).then(function(value) {
        console.log("Transaction complete");
        console.log(value);
      }).catch(function(e) {
        console.log(e);
        console.log("Error Modify publishing policy; see log.");
      });
    },

  getApplicationPolicy: function(index) {
          var self = this;
          ApplicationPolicyPublisher.deployed().then(function(instance) {
            return instance.getApplicationPolicy.call(parseInt(index), {from: account, gas:4700000});
          }).then(function(value) {
            console.log("Application Policy Details: ");
            console.log("Policy Information:  ", value[0]);
            console.log("Linked CA Id: ", value[2]);
            console.log("Application policy Status: ", value[3]);
            console.log("Notification: ", value[1]);
          }).catch(function(e) {
            console.log(e);
            console.log("Error get publishing policy; see log.");
          });
     },

};

var usrObj = Object.create(App);
setWeb3Provider();

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
