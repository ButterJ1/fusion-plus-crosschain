// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICrossChainHTLC {
    struct HTLCOrder {
        address sender;
        address receiver;
        uint256 amount;
        bytes32 hashlock;
        uint256 timelock;
        bool withdrawn;
        bool refunded;
        uint256 srcChainId;
        uint256 dstChainId;
        address srcToken;
        address dstToken;
    }

    event HTLCCreated(
        bytes32 indexed orderId,
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        bytes32 hashlock,
        uint256 timelock,
        uint256 srcChainId,
        uint256 dstChainId
    );

    event HTLCWithdrawn(bytes32 indexed orderId, bytes32 preimage);
    event HTLCRefunded(bytes32 indexed orderId);

    function createHTLC(
        address receiver,
        bytes32 hashlock,
        uint256 timelock,
        uint256 dstChainId,
        address srcToken,
        address dstToken,
        uint256 amount
    ) external payable returns (bytes32 orderId);

    function withdraw(bytes32 orderId, bytes32 preimage) external;
    function refund(bytes32 orderId) external;
    function getHTLC(bytes32 orderId) external view returns (HTLCOrder memory);
}