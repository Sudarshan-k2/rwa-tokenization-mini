// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AssetToken is ERC721, AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    uint256 public tokenIdCounter;

    struct Asset {
        string metadataURI;
        bool verified;
    }

    mapping(uint256 => Asset> public assets;

    constructor() ERC721("RWAAssetToken", "RWA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VERIFIER_ROLE, msg.sender);
    }

    function onboardAsset(string memory metadataURI) external returns (uint256) {
        uint256 newId = ++tokenIdCounter;
        assets[newId] = Asset(metadataURI, false);
        return newId;
    }

    function verifyAsset(uint256 assetId) external onlyRole(VERIFIER_ROLE) {
        require(!assets[assetId].verified, "Already verified");
        assets[assetId].verified = true;
    }

    function mintToken(address investor, uint256 assetId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(assets[assetId].verified, "Asset not verified");
        _mint(investor, assetId);
    }

    function redeem(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        _burn(tokenId);
        delete assets[tokenId];
    }
}
