// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IAuditReport {
    function thresoldPoint() external returns (uint256);

    function leaderboard(address user) external returns (uint256);
}

contract ARNFT is ERC721 {
    uint256 private _nextTokenId;

    address public immutable owner;

    string public baseURI;

    IAuditReport reportContract;

    constructor(
        string memory name,
        string memory symbol,
        address contractAddr
    ) ERC721(name, symbol) {
        owner = msg.sender;
        reportContract = IAuditReport(contractAddr);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function safeMint(address to) public {
        uint256 minPoint = reportContract.thresoldPoint();
        uint256 userPoint = reportContract.leaderboard(msg.sender);

        require(minPoint <= userPoint, "ARNFT: Not enough points!");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function setBaseURI(string memory _uri) external {
        require(owner == msg.sender, "ARNFT: user is not authorized!");
        baseURI = _uri;
    }
}
