pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
 
contract APIConsumer is ChainlinkClient {
  
    uint256 public volume;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Chainlink - 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Chainlink - 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     */
    constructor() public {
        setPublicChainlinkToken();  //this function tells our smart contract what the address of the LINK token is on the network we are on
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e; //The oracle contract is the node that is running the job/job id
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";  // we're trying to specify which job we want to use for our API request
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        
        // An oracle here is an oracle contract which is a smart contract that sits between other smart contracts and a chainlink node, 
        // It acts like a middle man and takes requests and passes them through a chainlink node, 
        // it then gets responses back from a chainlink node and then passes them back to the smart contracts  
    }
    
    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     ************************************************************************************
     *                                    STOP!                                         * 
     *         THIS FUNCTION WILL FAIL IF THIS CONTRACT DOES NOT OWN LINK               *
     *         ----------------------------------------------------------               *
     *         Learn how to obtain testnet LINK and fund this contract:                 *
     *         ------- https://docs.chain.link/docs/acquire-link --------               *
     *         ---- https://docs.chain.link/docs/fund-your-contract -----               *
     *                                                                                  *
     ************************************************************************************/
    function requestVolumeData() public returns (bytes32 requestId) 
    {
        /*
        - What we're doing here is creating a Request object here and calling it Request. 
        - We're storing it in memory here, where you can specify memory or storage. 
        - Sometimes you need to specify one or the other but in this case, you're just specifying memory
        
        - in this case we're calling the build chainlink request function and passing in the fields - job ID from above, smart contract in address(this), 
        - and we're calling through the fulfill function. 
        - This basically tells us what is the function that we want to run when we get a response  
        - as you can see there's a fulfill function below and so all we're doing in the request is when you get a request from an api call, send the call to this function (this.fulfill)
        
        */
        
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        // Here abovc, we need to specify what the api call we want to make. In this case we want to call a http get from the specified link
        
        
        // Set the path to find the desired data in the API response, where the response format is: - similar to Git where it's like a folder branch location
        // {"RAW":
        //      {"ETH":
        //          {"USD":
        //              {
        //                  ...,
        //                  "VOLUME24HOUR": xxx.xxx,
        //                  ...
        //              }
        //          }
        //      }
        //  }
        request.add("path", "RAW.ETH.USD.VOLUME24HOUR");
        
        // Multiply the result by 1000000000000000000 to remove decimals -- this is because in solidity it can't handle floating point numbers
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // Sends the request -- sends this back to the oracle contract and pay the fee which is defined up at the top in the constructor
        return sendChainlinkRequestTo(oracle, request, fee);
        
                /* ---------------------------------------------------------- CONTROL FLOW ----------------------------------------------------------
    
     - So when we run the return function "return sendChainlinkRequestTo(oracle, request, fee);"
     - we're going to send the fee and send that request (sendChainlinkRequestTo()) to the oracle contract and emit data to the blockchain
     - the chainlink node that runs that node will see that data and see that here's a job for me to run 
     - it will perform an api request and get the result that we want
     - it will then send the result back to the oracle contract
     - The oracle contract will then go and call the fulfill function now and parse in the volume result we got and store it in this smart contract here
     - It's like a request and recieve model where:
                        - in your smart contract you make a request
                        - a chainlink node gets that request 
                        - and then in another transaction subsequently it will post a response and come back into your smart contract
                        - it's not an instant thing like the price feeds, it's a multi step thing that happens over multiple transactions 
    
                 */
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId)
    {
        volume = _volume;
    }
    
    /**
     * Withdraw LINK from this contract
     * 
     * NOTE: DO NOT USE THIS IN PRODUCTION AS IT CAN BE CALLED BY ANY ADDRESS.
     * THIS IS PURELY FOR EXAMPLE PURPOSES ONLY.
     */
    function withdrawLink() external {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
    

}
