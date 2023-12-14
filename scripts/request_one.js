const ethers = require("ethers");
const airnodeAdmin = require("@api3/airnode-admin");
const { decode } = require("@api3/airnode-abi");
require("dotenv").config();
const ABI = require("./abi.json");

async function main() {

  const airnodeAddress = "0x6238772544f029ecaBfDED4300f13A3c4FE84E1D";
  const endPointAddress = "0x94555f83f1addda23fdaa7c74f27ce2b764ed5cc430c66f5ff1bcf39d583da36";
  const endPoint256Address = "0x9877ec98695c139310480b4323b9d474d48ec4595560348a2341218670f7fbc2";
  const SponsorWallet = "0xB4d8d0A0D243e993D6C939a9fdA681b2dbCDc5b9";
  //const contractAddress = "your_contract_address";
  const contractAddress = "0xce5f4055a1B876e37A4Bdb52BE23cb1dB4eBa0B7";

  // Connect to a provider (e.g., Infura, Alchemy)
  const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL);
  // Use your private key (keep this secure!)
  const privateKey = process.env.PRIVATE_KEY;
  const wallet = new ethers.Wallet(privateKey, provider);

  // Smart contract ABI and address
  const contractABI = ABI;

  // Create a contract instance
  const contract = new ethers.Contract(contractAddress, contractABI, wallet);

  // console.log(
  //   "Setting Params, waiting for it to be confirmed..."
  // );

  // const receipt = await contract.setRequestParameters(
  //   airnodeAddress,
  //   endPointAddress,
  //   endPoint256Address,
  //   SponsorWallet
  // );

  // let txReceipt = await receipt.wait();
  // if (txReceipt.status === 0) {
  //   throw new Error("Transaction failed");
  // }
  // console.log(
  //   "Request Parameters set"
  // );

  // Make request for random number
  console.log(
    "Requesting Random Number..."
  );
  const requestRandomNumber = await contract.makeRequestUint256();

  let requestID;
  // Listen for all events from the contract
  contract.once("*", (event) => {
    // filter out with the specific transaction hash
    if (event.log.transactionHash === requestRandomNumber.hash) {
      requestID = event.args[0];
      console.log("requestID: ", requestID);
    }
 });
  
  let txReceipt2 = await requestRandomNumber.wait();
  if (txReceipt2.status === 0) {
    throw new Error("Transaction failed");
  }
  console.log(
    "Random Number Requested..."
  )

  const response = await new Promise((resolve) => {
    contract.once(contract.filters.ReceivedUint256(requestID, null), (event) => {
      resolve(event);
    });

  });

  // console.log("Response:", response.log.data);
  const hexvalue = response.log.data;
  const decimal = BigInt(hexvalue);
  console.log("Randon Number Received:", decimal);
} 

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
