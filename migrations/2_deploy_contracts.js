var PolicyContract = artifacts.require("PolicyContract");
var ApplicationPolicyContract = artifacts.require("ApplicationPolicyPublisher");

module.exports = function(deployer) {
  deployer.deploy(PolicyContract, {gas:2000000});
  deployer.deploy(ApplicationPolicyContract, {gas:2500000});
};
