pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
 
/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor() 
    
    // In our constructor we are calling the VRFConsumerBase contract and calling for the VRF Coordinator address and the link Token
    // VRF Coordinator is the smart contract that sits between smart contracts that want randomness and the chainlink node that fulfills the randomness Request
    // The LINK token is the address of the link token on the specified network
    // This can found on the docs for randomness
    
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
    /** 
     * Requests randomness 
     * It's a public function
     * it's calling for the requestRandomness function from the VRFConsumerBase import library
     * it's parsing in key hash and the fee
     * so then we go to the VRF Coordinator contract, the VRF Coordinator contrcat will then send a request to the chainlink node and do a random number request and then send a number back to the VRF number contract
     * The VRF Coordinator contract will then verify that its been created with the seed thats been generated when it sent a request for the node, by using the node's public key
     * It will then specifically look for a fulfillRandomness function in your consumer contract
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet"); // this is just a validation criteria to make sure you have enough link to run the contract
        return requestRandomness(keyHash, fee);
    }
 
    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
 
    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
