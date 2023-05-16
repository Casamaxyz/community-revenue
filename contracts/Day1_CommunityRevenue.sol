// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * This is the simplest possible method of Splitting Revenue between two parties.
 * It is a simple contract that mints an NFT and splits the revenue between the Kernel Public Goods Treasury and the Artist.
 * This is completely unaudited and if you use this code you are doing so at your own risk.
 */

contract CommunityRevenue is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Address of the Kernel Public Goods Payout Address on Optimsm
    // https://app.optimism.io/retropgf-discovery/0xC728DEa8B2972E6e07493BE8DC2F0314F7dC3E98
    address payable public KernelTreasury = payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    // Address of the Casama Multsig on Optimism
    address payable public CasamaMultSig = payable(0xD2Ab2784BB40EdA525464e966362507dD6D6b830);


    uint256 public constant _costToMint = 0.003 ether;
    uint256 public revenueForKernel;
    uint256 public revenueForArtist;

    

    constructor() ERC721("CommunityRevenue", "CR") {}

    function mintNFT() public payable returns (uint256) {
        require(msg.value == _costToMint, "Must send 0.003 ether");
        
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, "https://gateway.pinata.cloud/ipfs/QmTazALEVupiMwi2CReEbUp41DHLQcJpWJS2S9Crk7rnqD");
        _tokenIds.increment();
        return newItemId;
    }

    function _splitRevenue() internal {
        uint256 _revenue = address(this).balance;
        revenueForKernel = (_revenue * 80) / 100;
        revenueForArtist = (_revenue * 20) / 100;

    }

    function withdraw() public onlyOwner {
        _splitRevenue();
        KernelTreasury.transfer(revenueForKernel);
        payable(owner()).transfer(revenueForArtist);
    }

}
