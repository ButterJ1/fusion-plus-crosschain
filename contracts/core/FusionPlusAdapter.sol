// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ICrossChainHTLC.sol";

contract FusionPlusAdapter is ReentrancyGuard, Ownable {
    ICrossChainHTLC public immutable htlcContract;
    
    struct CrossChainOrder {
        address maker;
        address srcToken;
        address dstToken;
        uint256 srcAmount;
        uint256 dstAmount;
        uint256 srcChainId;
        uint256 dstChainId;
        uint256 deadline;
        bytes32 salt;
    }

    mapping(bytes32 => bool) public filledOrders;
    mapping(address => bool) public authorizedResolvers;

    event CrossChainOrderCreated(
        bytes32 indexed orderHash,
        address indexed maker,
        CrossChainOrder order
    );

    event CrossChainOrderFilled(
        bytes32 indexed orderHash,
        address indexed resolver,
        bytes32 htlcId
    );

    modifier onlyAuthorizedResolver() {
        require(authorizedResolvers[msg.sender], "Unauthorized resolver");
        _;
    }

    constructor(address _htlcContract) Ownable(msg.sender) {
        htlcContract = ICrossChainHTLC(_htlcContract);
    }

    function authorizeResolver(address resolver) external onlyOwner {
        authorizedResolvers[resolver] = true;
    }

    function revokeResolver(address resolver) external onlyOwner {
        authorizedResolvers[resolver] = false;
    }

    function createCrossChainOrder(
        CrossChainOrder calldata order,
        bytes calldata signature
    ) external returns (bytes32 orderHash) {
        orderHash = keccak256(abi.encode(order));
        require(!filledOrders[orderHash], "Order already filled");
        require(block.timestamp < order.deadline, "Order expired");
        require(order.maker == msg.sender, "Invalid maker");

        // Validate signature (simplified for demo)
        // In production, implement proper EIP-712 signature validation

        emit CrossChainOrderCreated(orderHash, order.maker, order);
        return orderHash;
    }

    function fillCrossChainOrder(
        CrossChainOrder calldata order,
        bytes32 preimage,
        uint256 timelock
    ) external onlyAuthorizedResolver returns (bytes32 htlcId) {
        bytes32 orderHash = keccak256(abi.encode(order));
        require(!filledOrders[orderHash], "Order already filled");
        require(block.timestamp < order.deadline, "Order expired");

        bytes32 hashlock = sha256(abi.encodePacked(preimage));
        
        htlcId = htlcContract.createHTLC(
            order.maker,
            hashlock,
            timelock,
            order.dstChainId,
            order.srcToken,
            order.dstToken,
            order.srcAmount
        );

        filledOrders[orderHash] = true;

        emit CrossChainOrderFilled(orderHash, msg.sender, htlcId);
        return htlcId;
    }
}