## QRNG Example - Foundry

> An example project that demonstrates the usage of the Airnode request–response protocol to receive API3 QRNG services

This README documents this specific QRNG example implementation. For more general information, refer to the
[API3 QRNG docs](https://docs.api3.org/qrng/).

## Instructions

1. Install dependencies
```shell
forge install
```

Install local script dependencies (javascript)
```shell
yarn install
```


2. Provide the blockchain provider URL and the wallet private key for the network you will work with in a .env file. The wallet needs to
   be funded.

```sh
PRIVATE_KEY = "YOUR_PRIVATE_KEY"
PROVIDER_URL = https://rpc.ankr.com/eth_sepolia
```

3. Deploy the contract

### Deploy

```shell
$ forge script script/DeployQRNG.s.sol:DeployQRNG --rpc-url <your_rpc_url> --private-key <your_private_key>
```

4. Run the script `fund_rrp.js` in scripts folder to generate the sponsor wallet and fund it with 0.01 of native gas token.

Make sure to update `YourDeployedContractAddress` with your deployed contract
```shell
node scripts\fund_rrp.js
```

5. Run the script `request_rrp.js` in scripts folder to set up the Request Parameters `setRequestParameters` and call `makeRequestUint256` that will return us a single random number.

Make sure to update `sponsorWallet` with your previously generated sponsor wallet address
Make sure to update `contractAddress` with your deployed contract address

```sh
node scripts\request_rrp.js
```

or send funds to sponsor wallet address displayed on the terminal manually.

The sponsor can
[request a withdrawal](https://docs.api3.org/airnode/latest/reference/packages/admin-cli.html#request-withdrawal) from
the sponsor wallet, yet this functionality is not implemented in the example contract for brevity.



## QrngExample contract documentation

### Request parameters

The contract uses the following parameters to make requests:

- `airnode`: Airnode address that belongs to the API provider
- `endpointId`: Airnode endpoint ID that will be used. Different endpoints are used to request a `uint256` or
  `uint256[]`
- `sponsorWallet`: Sponsor wallet address derived from the Airnode extended public key and the sponsor address

`airnode` and `endpointId` are read from `scripts/apis.js`, see below for how to derive `sponsorWallet`. For further
information, see the [docs on Airnode RRP concepts](https://docs.api3.org/airnode/latest/concepts/).

### Sponsor wallet

QrngExample sets its own sponsorship status as `true` in its constructor. This means that QrngExample is its own
sponsor. You can derive the sponsor wallet using the following command (you can find `<XPUB>` and `<AIRNODE>` in
`scripts/apis.js`):

```sh
npx @api3/airnode-admin derive-sponsor-wallet-address \
  --airnode-xpub <XPUB> \
  --airnode-address <AIRNODE> \
  --sponsor-address <QRNG_EXAMPLE_ADDRESS>
```

The Airnode will use this sponsor wallet to respond to the requests made by QrngExample. This means that you need to
keep this wallet funded.

The sponsorship scheme can be used in different ways, for example, by having the users of your contract use their own
individual sponsor wallets. Furthermore, sponsors can request withdrawals of funds from their sponsor wallets. For more
information about the sponsorship scheme, see the
[sponsorship docs](https://docs.api3.org/airnode/latest/concepts/sponsor.html).

### ABI-encoding

Fulfillment data is ABI-encoded, and in `bytes` type. It is assumed that you know the expected response schema
associated with the endpoint that you use to make your request. For example, `makeRequestUint256()` uses an endpoint
that will return `(uint256)`, while `makeRequestUint256Array()` uses an endpoint that will return `(uint256[])`. Then,
the respective fulfillment function should decode the response using `abi.decode()` with the correct schema.

Request parameters are encoded using "Airnode ABI", which should not be confused with regular ABI encoding. QrngExample
already implements this encoding and provides a user-friendly interface for `makeRequestUint256Array()`. Read the
[ABI encoding docs](https://docs.api3.org/airnode/latest/reference/specifications/airnode-abi-specifications.html) for
more information.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```