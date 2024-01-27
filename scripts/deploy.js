// imports
const { ethers, run, network } = require("hardhat");

// async main
async function main() {
  const AuditReport = await ethers.getContractFactory("AuditReport");
  console.log("Deploying contract...");
  const auditreport = await AuditReport.deploy("www.xyz.com", 50);

  console.log(
    `The AuditReport Contract is Deployed in address: ${auditreport.address}`
  );

  if (hre.network.name != "hardhat") {
    console.log("Waiting for block confirmations...");
    await auditreport.deployTransaction.wait(6);
    await verify(auditreport.address, ["www.xyz.com", 50]);
  }

  const Arnft = await ethers.getContractFactory("ARNFT");
  console.log("Deploying contract...");
  const name = "My Audit NFT";
  const symbol = "MRN";

  const _arnft = await Arnft.deploy(name, symbol, auditreport.address);

  console.log(`The ARNFT Contract is Deployed in address: ${_arnft.address}`);

  if (hre.network.name != "hardhat") {
    console.log("Waiting for block confirmations...");
    await _arnft.deployTransaction.wait(6);
    await verify(_arnft.address, [name, symbol, auditreport.address]);
  }
}

// async function verify(contractAddress, args) {
const verify = async (contractAddress, args) => {
  console.log("Verifying contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified!");
    } else {
      console.log(e);
    }
  }
};

// main
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
