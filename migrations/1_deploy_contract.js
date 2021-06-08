const IbizaNFT = artifacts.require("IbizaNFT");

module.exports = function (deployer) {
  deployer.deploy(IbizaNFT, "IbizaNFT", "INFT", "https://www.google.com/");
};
