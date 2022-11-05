// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title ERC721 smart contract.
 *
 */
contract NFTContract is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public maxSupply = 100;
    uint256 public testPrice = 0.001 ether;
    bool public saleOpen = false;
    uint256 public maxMintAllowedOnce = 25;

    // baseURI for meta files
    string public baseURI ;
    string public baseExtension = ".json";

    // revealed uri
    string public notRevealedUri;
    bool public revealed = false;

    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721("NFT Template", "NFT") {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(_mintAmount > 0 && _mintAmount <= maxMintAllowedOnce, "Must mint less than or equal to max allowed at a time");
        require(supply + _mintAmount <= maxSupply, "Must mint less than the max supply of tokens");

        if (msg.sender != owner()) {
            require(saleOpen, "Sorry!! can't mint when sale is closed");
            require(msg.value >= testPrice * _mintAmount, "Must send proper eth value to mint");
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function tokensOfOwner(address _owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token" );
        if (revealed == false) {
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ?
            string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    // set baseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // toggles reveal
    function toggleReveal() public onlyOwner() {
        revealed = true;
    }

    // sets price of NFT
    function setPrice(uint256 _price) public onlyOwner() {
        testPrice = _price;
    }

    // toggles enable or disable sale
    function toggleSale() public onlyOwner() {
        saleOpen = !saleOpen;
    }

    function getBaseURI() public view returns (string memory) {
        if(revealed) return baseURI;
        return notRevealedUri;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    // withdraw funds
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        payable(owner()).transfer(bal);
    }
}