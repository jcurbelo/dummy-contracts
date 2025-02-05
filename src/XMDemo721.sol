// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.28;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @custom:security-contact robin@crossmint.com
contract XMDemo721 is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable
{
    uint256 private _nextTokenId;
    string private _tokenURI;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string calldata __tokenURI) public initializer {
        __ERC721_init("XMDemo", "XMD");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Ownable_init(_msgSender());
        _tokenURI = __tokenURI;
    }

    function mint(address recipient, uint256 quantity) external {
        for (uint256 i = 0; i < quantity; ) {
            unchecked {
                ++_nextTokenId;
                ++i;
            }
            _safeMint(recipient, _nextTokenId);
        }
    }

    function setTokenURI(string calldata __tokenURI) external onlyOwner {
        _tokenURI = __tokenURI;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        if (bytes(_tokenURI).length == 0) {
            return super.tokenURI(tokenId);
        }
        return _tokenURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721URIStorageUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
