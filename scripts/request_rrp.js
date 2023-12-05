const ethers = require("ethers");
const airnodeAdmin = require("@api3/airnode-admin");
require("dotenv").config();
const ABI = require("./abi.json");

async function main() {

  const airnodeAddress = "0x6238772544f029ecaBfDED4300f13A3c4FE84E1D";
  const endPointAddress = "0x94555f83f1addda23fdaa7c74f27ce2b764ed5cc430c66f5ff1bcf39d583da36";
  const endPoint256Address = "0x27cc2713e7f968e4e86ed274a051a5c8aaee9cca66946f23af6f29ecea9704c3";
  const SponsorWallet = "0x2EA8648C184b68eC6d98493bd8e9a4d6f768154D";

  // Connect to a provider (e.g., Infura, Alchemy)
  const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL);
  // Use your private key (keep this secure!)
  const privateKey = process.env.PRIVATE_KEY;
  const wallet = new ethers.Wallet(privateKey, provider);

  // Smart contract ABI and address
  const contractABI = ABI;
  //const contractAddress = "your_contract_address";
  const contractAddress = "0x11924f1eDcCD4DBf1B7f10Ed80b79177a7643bD7";

  // Create a contract instance
  const contract = new ethers.Contract(contractAddress, contractABI, wallet);

  console.log(
    "Setting Params, waiting for it to be confirmed..."
  );

  const receipt = await contract.setRequestParameters(
    airnodeAddress,
    endPointAddress,
    endPoint256Address,
    SponsorWallet
  );

  let txReceipt = await receipt.wait();
  if (txReceipt.status === 0) {
    throw new Error("Transaction failed");
  }
  console.log(
    "Request Parameters set"
  );

  // Make request for random number
  console.log(
    "Requesting Random Number..."
  );
  const requestRandomNumber = await contract.makeRequestUint256();
  
  let txReceipt2 = await requestRandomNumber.wait();
  if (txReceipt2.status === 0) {
    throw new Error("Transaction failed");
  }
  console.log(
    "Random Number Requested"
  )
  

  //////
   // and read the logs once it gets confirmed to get the request ID
   console.log("Waiting for the request to be fulfilled...");
   const requestId = await new Promise((resolve) =>
   contract.once(requestRandomNumber.hash, (tx) => {
     // We want the log from RrpRequesterContract
     const log = tx.logs.find(
       (log) => log.address === contractAddress
     );
     const parsedLog = contract.interface.parseLog(log);
     resolve(parsedLog.args.requestId);
   })
 );
 console.log(`Transaction is confirmed, request ID is ${requestId}`);

//  // Wait for the fulfillment transaction to be confirmed and read the logs to get the random number
//  console.log("Waiting for the fulfillment transaction...");
//  const log = await new Promise((resolve) =>
//    hre.ethers.provider.once(
//      RrpRequesterContract.filters.RequestFulfilled(requestId, null),
//      resolve
//    )
//  );
//  const parsedLog = RrpRequesterContract.interface.parseLog(log);
//  const decodedData = parsedLog.args.response;
//  console.log(
//    `Fulfillment is confirmed, response is ${decodedData.toString()}`
//  );
 /////////////
  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
