## Smart Contract assisted Public Key Infrastructure

###Pre-requisite
1. Have etherium(e.g., geth or testrpc client) running in the background. For testing, it is faster to test with testrpc client
2. Install truffle framework

###To Run
1. Clone this application directory. This downloads the necessary code and truffle data structure to run this application
```
$ git clone scp
```
2. Migrate the smart contract to the etherium chain
```
$ truflle migrate
```
Before running the `migrate`, check `truffle.js` has the proper parameter matched with the deployed blockchain
3. 
3. npm dev run
4. open a tunnel (8080) from host to guest, if your are testing from Host while the etherium chain is running in a Guest VM

Directory Structure
-------------------
app/javascripts/apptest.js: a command line tools for interacting with
                the contrat
                
```
    node apptest.js
```

                
app/javascripts/app.js: Works in conjuction with index.html to provide GUI value.
                
Manual Testing
--------------
Run truffle console> 

``` javascripts
    SmartPKI.deployed().then(function(instance){ console.log(instance.address); }).catch(function(err) { });
```
