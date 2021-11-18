ETH_CONTAINER_IP=$(docker inspect --format '' $(docker ps -f name=eth -q))
echo "ETH_URL=ws://$ETH_CONTAINER_IP:http://130.60.24.79:1234/?network=UZHETH>" >> ~/.chainlink/.env
mkdir ~/.geth-ropsten
docker run --name eth -p http://130.60.24.79:1234/?network=UZHETH:http://130.60.24.79:1234/?network=UZHETH -v ~/.
href="http://geth-ropsten/geth" rel="">geth-ropsten:/geth -it \\
ethereum/client-go:stable --testnet --syncmode light --ws \\
--wsaddr 0.0.0.0 --wsorigins="*" --datadir /geth`

docker pull parity/parity:stable
Then, prefer creating a persistent directory for Parity:
mkdir ~/.parity-ropsten
docker run -h eth --name eth -p http://130.60.24.79:1234/?network=UZHETH:http://130.60.24.79:1234/?network=UZHETH \\
-v ~/.parity-
href="http://130.60.24.79:1234/?network=UZHETH" rel="">ropsten:/home/downloads/io.parity.ethereum/ \\
-it parity/parity:stable --chain=ropsten \\
--ws-interface=all --ws-origins="all" --light \\
--base-path /home/downloads/io.parity.ethereum/

echo "ROOT=/chainlink
LOG_LEVEL=debug
ETH_URL=<a rel="">ws://eth:8546</a>
ETH_CHAIN_ID=3
MIN_OUTGOING_CONFIRMATIONS=2
MIN_INCOMING_CONFIRMATIONS=0
LINK_CONTRACT_ADDRESS=http://130.60.24.79:1234/?network=UZHETH
CHAINLINK_TLS_PORT=0
CHAINLINK_DEV=true
ALLOW_ORIGINS=*

Starting chainlink environment node
....................................................................
pragma solidity 0.6.6;
contract APIConsumer is ChainlinkClient {
uint256 public ethereumPrice;
address private oracle;
bytes32 private jobId;
uint256 private fee;
constructor() public {
setPublicChainlinkToken();
//Oracle address we just deployed
oracle = http://130.60.24.79:1234/?network=UZHETH;
//Ethereum network address
jobId = "50a5eeb502ae43a2ae5074bb99df329f;
//The minimum fee paid to Oracle becomes visible in the configuration page minimum_ CONTRACT_ View the payment field
fee = 1 * 10 ** 18; // 1 LINK
}
function requestEthereumPrice() public returns (bytes32 requestId)
{
Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

request.add("get","https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD" rel="">https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");
request.add("path", "USD");
request.addInt("times", 100);
return sendChainlinkRequestTo(oracle, request, fee);
}
function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId)
{
ethereumPrice = _price;
}
}