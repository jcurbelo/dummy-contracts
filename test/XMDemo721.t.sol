// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {XMDemo721} from "../src/XMDemo721.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract XMDemo721Test is Test {
    XMDemo721 public implementation;
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

        // Deploy implementation
        implementation = new XMDemo721();

        // Deploy proxy
        bytes memory initData = abi.encodeWithSelector(
            XMDemo721.initialize.selector,
            INITIAL_URI
        );
        ERC1967Proxy proxyContract = new ERC1967Proxy(
            address(implementation),
            initData
        );
        proxy = XMDemo721(address(proxyContract));

        // Set owner as the msg.sender for subsequent calls
        vm.startPrank(owner);
    }

    function test_Initialization() public view {
        assertEq(proxy.name(), "XMDemo");
        assertEq(proxy.symbol(), "XMD");
        assertEq(proxy.owner(), owner);
    }

    function test_ImplementationContractLocked() public {
        vm.expectRevert("Initializable: contract is already initialized");
        implementation.initialize(INITIAL_URI);
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
        vm.expectRevert("Ownable: caller is not the owner");
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
        vm.expectRevert("ERC721: caller is not token owner or approved");
        proxy.transferFrom(user1, user2, 1);
    }
}
