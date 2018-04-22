## Smart Contract assisted Public Key Infrastructure (SCP)
SCP uses blockchain as a tool to mitigate the trusted third party
weakness in the Web PKI systems. It enables, application provider (e.g.,
Browser vendors) to set trust for a CA. Thus, trust in the PKI
is defined by the trust consuming entity (e.g., browser vendors).
A domain owner can request for certificate which is trusted by
specifi browsers.

Note: The code is in prototype phase, illustrating the idea. For details,
contact the author 

###Pre-requisite
1. Have etherium(e.g., geth or testrpc client) running in the background. For testing, it is faster to test with testrpc client
2. Install truffle framework

###To Run and Test
1. Clone this application directory. This downloads the necessary code and truffle data structure to run this application
```
$ git clone scp
```
2. Migrate the smart contract to the etherium chain
```
$ truflle migrate
```
Before running the `migrate`, check `truffle.js` has the proper parameter matched with the deployed blockchain. The `migrate` command migrates the `PolicyContract` and `ApplicationPolicyPublisher` smart contract to the etherium chain. After succesful migration, you will get contract address. For example,
```
 PolicyContract: 0x8b7c3ff03a833c82909a8d306587d2612e632463
 ApplicationPolicyPublisher: 0x84f3d49c32f87e26208ab3d4162c4e3c5b51061d
```
3. Pre-initialize the smart contract. To do this, go to the truffle console
```
$ truffle console
```
First setup a application policy for a CA. This operation is assumed to be performed by a Browser vendor.
It assumed there is already a CA policy with id `CaId:1234`. Here, for simplicity, all browser vendors
performed the operation in a single transaction. In other words, this operation can be performed
by a trusted thrid party who monitors the browser's truststore and pushes transaction to the chain.
An example of such is TownCrier model
```
truffle(development)> ApplicationPolicyPublisher.deployed().then (function(instance) { return instance.publishApplicationPolicy(0, "{ PolicyId: EV Server Authentication (1.3.6.1.4.1.311.94.1.1), Policies: { applications: [ app: { name: Chrome, status: trusted}, app: { name:Apple, status: trusted}, app:{ name:Android, status: NA}, app: { name: Mozilla, status: trusted, notice: Unitl Jan 2019} ] } }" , "CaId:1234","true"); }).then(function(result){ console.log(result); }).catch(function (e){ console.log("error"); })
```

Second, check that the appplication policy exists. Policies are entered sequentially, starting from 0.
```
truffle(development)> ApplicationPolicyPublisher.deployed().then (function(instance) { return instance.getApplicationPolicy(0); }).then(function(result){ console.log(result); }).catch(function (e){ console.log("error"); })

```

4. A domain owner requests for a domain from the CA. Before that, the domain owner request a policycontract from the CA.
The CA knows its published policy e.g., PolicyId: EV Server Authentication (1.3.6.1.4.1.311.94.1.1 and it own Ca ID e.g.,
CaId=1234.

The address of the ApplicationPolicy contract is known to the CA. The CA can query the ApplicationPolicy address to find
all policy index relevant for this policyID.

The CA then creates a policy contract
```
truffle(development)> PolicyContract.deployed().then (function(instance) { return instance.publishCAtoDomainPolicyContract(1,"0x84f3d49c32f87e26208ab3d4162c4e3c5b51061d", 0,"req:201"); }).then(function(result){ console.log(result); }).catch(function (e){ console.log("error"); })
```
This creates a new policyContract. The address the policycontract and index of value is returned to the domain owner.
e.g., address= 0x8b7c3ff03a833c82909a8d306587d2612e632463
      index = 1

5. Domain owner request certificate using the adrress and index value included in the CSR

6. The certificate includes these two fields as `certificate policies` metadata

7. Any client (e.g., browser, or domain owner) can verify the current state of trust by querying the policycontract
using these two values.
```
truffle(development)> PolicyContract.deployed().then (function(instance) { return instance.verifyPolicyContract(1); }).then(function(result){ console.log(result); }).catch(function (e){ console.log("error"); })

```

### Test using NodeJs Client
NodeJs client in `app/javascript/appLoad.js` provides pretty printing for above functionalities.
```
    node appLoad.js
```

###Directory Structure
truffle.js: start script used by truffle
app/javascripts/appLoad.js: a command line tools for interacting with SmartContract. It also
   performs load testing the smart contracts
contracts/Migrations.sol: Migration contract for udpating the smart contract
contracts/TransparentContractCA.sol: Includes two smart contract - ApplicationPolicyPublisher, PolicyContract
migrations/2_deploy_contracts.js: migration script

### Contact and License


