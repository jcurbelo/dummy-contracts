// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {XMDemo721} from "../src/XMDemo721.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract XMDemo721Test is Test {
    XMDemo721 public proxy;
    address public owner;
    address public user1;
    address public user2;
    string public constant INITIAL_URI = "ipfs://initial-uri/";
    string public constant NEW_URI = "ipfs://new-uri/";

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.startPrank(owner);
        // Deploy proxy using the OpenZeppelin Upgrades library
        address proxyAddress = Upgrades.deployTransparentProxy(
            "XMDemo721.sol",
            owner, // proxy admin owner
            abi.encodeCall(XMDemo721.initialize, (INITIAL_URI))
        );
        proxy = XMDemo721(proxyAddress);
    }

    function test_Initialization() public view {
        assertEq(proxy.name(), "XMDemo");
        assertEq(proxy.symbol(), "XMD");
        assertEq(proxy.owner(), owner);
    }

    function test_Minting() public {
        proxy.mint(user1, 1);
        assertEq(proxy.balanceOf(user1), 1);
        assertEq(proxy.ownerOf(1), user1);

        // Test batch minting
        proxy.mint(user2, 3);
        assertEq(proxy.balanceOf(user2), 3);
        assertEq(proxy.ownerOf(2), user2);
        assertEq(proxy.ownerOf(3), user2);
        assertEq(proxy.ownerOf(4), user2);
    }

    function test_TokenURI() public {
        proxy.mint(user1, 1);
        assertEq(proxy.tokenURI(1), INITIAL_URI);

        // Test URI update
        proxy.setTokenURI(NEW_URI);
        assertEq(proxy.tokenURI(1), NEW_URI);
    }

    function test_TokenURIUpdateOnlyOwner() public {
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OwnableUnauthorizedAccount(address)",
                user1
            )
        );
        proxy.setTokenURI(NEW_URI);
    }

    function test_Enumerable() public {
        proxy.mint(user1, 3);

        assertEq(proxy.totalSupply(), 3);
        assertEq(proxy.tokenOfOwnerByIndex(user1, 0), 1);
        assertEq(proxy.tokenOfOwnerByIndex(user1, 1), 2);
        assertEq(proxy.tokenOfOwnerByIndex(user1, 2), 3);

        assertEq(proxy.tokenByIndex(0), 1);
        assertEq(proxy.tokenByIndex(1), 2);
        assertEq(proxy.tokenByIndex(2), 3);
    }

    function test_TransferToken() public {
        proxy.mint(user1, 1);

        vm.stopPrank();
        vm.startPrank(user1);
        proxy.transferFrom(user1, user2, 1);

        assertEq(proxy.ownerOf(1), user2);
        assertEq(proxy.balanceOf(user1), 0);
        assertEq(proxy.balanceOf(user2), 1);
    }

    function test_SupportsInterface() public view {
        // Test ERC721 interface
        assertTrue(proxy.supportsInterface(0x80ac58cd));
        // Test ERC721Metadata interface
        assertTrue(proxy.supportsInterface(0x5b5e139f));
        // Test ERC721Enumerable interface
        assertTrue(proxy.supportsInterface(0x780e9d63));
    }

    function testFuzz_Minting(uint8 quantity) public {
        vm.assume(quantity > 0 && quantity <= 100);

        proxy.mint(user1, quantity);
        assertEq(proxy.balanceOf(user1), quantity);

        for (uint256 i = 1; i <= quantity; i++) {
            assertEq(proxy.ownerOf(i), user1);
        }
    }

    function test_RevertWhen_TransferFromNonOwner() public {
        proxy.mint(user1, 1);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)",
                user2,
                1
            )
        );
        proxy.transferFrom(user1, user2, 1);
    }
}
