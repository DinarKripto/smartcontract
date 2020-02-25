var MyToken = artifacts.require("./DncToken.sol");

module.exports = function(deployer) {
  deployer.deploy(MyToken, "DinarCoin" , "DNC" , 18 , 1000000);
  
 
};