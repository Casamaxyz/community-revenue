// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * This is an updated contract that allows the deployer to set some parameters for the contract.
 * The deployer can set the cost to mint, the address of the community treasury, and the share of revenue for the community.
 * WARNING: This is contract is unaudited and if you use this code you are doing so at your own risk.
 */

contract CommunityRevenue is ERC721URIStorage, Ownable {

    // Used for generating the token ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Address of Recipients of Revenue
    address payable public communityTreasury;
    address payable public artistPayoutAddress;

    // Cost per mint, and share splits
    uint256 public costToMint;
    uint256 public shareForCommunity;
    uint256 public shareForArtist;

    // Used for withdrawals
    uint256 public revenueForCommunity;
    uint256 public revenueForArtist;
    bool public endMint = false;

    
    constructor(
        address payable _communityRecipient, 
        uint256 _costToMint,
        uint256 _shareForCommunity
    ) ERC721("CommunityRevenue", "CR") {
        require(endMint == false, "Minting has ended.");
        require(_shareForCommunity < 100 && _shareForCommunity > 0, "Share for community must be less than 100 or greater than 0");
        require(_communityRecipient != address(0), "Recipient cannot be the zero address");
        require(_costToMint > 0, "Cost to mint must be greater than 0");


        communityTreasury = _communityRecipient;
        artistPayoutAddress = payable(msg.sender);
        costToMint = _costToMint;
        shareForCommunity = _shareForCommunity;
        shareForArtist = 100 - _shareForCommunity;

    }

    function mintNFT() public payable returns (uint256) {
        require(msg.value == costToMint, "Must send 0.003 ether");
        
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, "https://gateway.pinata.cloud/ipfs/QmPntvmPECzzNbfEmHGzi3UURqmMhjjfdTnLcM4jjMog5m");
        _tokenIds.increment();
        return newItemId;
    }

    function _splitRevenue() internal {
        uint256 _revenue = address(this).balance;
        revenueForCommunity = (_revenue * shareForCommunity) / 100;
        revenueForArtist = (_revenue * shareForArtist) / 100;

    }

    function withdraw() public onlyOwner {
        endMint = true;
        _splitRevenue();
        communityTreasury.transfer(revenueForCommunity);
        payable(owner()).transfer(revenueForArtist);
    }


}
