// contracts/Vikings.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vikings is ERC721URIStorage, VRFConsumerBase, Ownable {
    using Counters for Counters.Counter; // counter from OZ
    Counters.Counter private _tokenIds;
    uint256 public CommonBoxPriceInUsd; // The Price of The common Box
    uint256 public EpicBoxPriceInUsd; // The Price of The Epic Box
    uint256 public LegendaryBoxPriceInUsd; // The Price of The Legendary Box
    AggregatorV3Interface internal priceFeed; // price Feed see oracle Chainlink
    mapping(RARITY => string) public VikingURI; // get Uri of a rarity
    mapping(uint256 => RARITY) public vikingRarity; // get rarity of an Id
    mapping(uint256 => uint256) public lastFight; // get last fight in seconds for an Id
    mapping(address => uint256) public playerBalance; // player Balance
    mapping(address => uint256) public lastClaim; // last claim of an address
    mapping(bytes32 => BOXRARITY) public boxRarityOfRequestId;
    mapping(bytes32 => uint256) public vikingIdOfRequestId;
    mapping(bytes32 => address) public requestIdToOwner;
    uint256[] public vikings; // array of 721 tokens
    IERC20 public vikingsGold; // Game Token
    uint256 internal fee;
    bytes32 internal keyHash;
    // events
    event newVikingBorn(
        uint256 indexed id,
        string URI,
        address owner,
        RARITY rarity
    );
    event fightFinished(uint256 indexed id, uint256 gain);
    event claimed(address player, uint256 balance);
    event requestToCreatNewViking(
        bytes32 indexed requestId,
        BOXRARITY box_rarity
    );
    // rarity
    enum RARITY {
        COMMON,
        RARE,
        SUPER_RARE,
        EPIC,
        LEGEND,
        SUPER_LEGEND
    }

    enum BOXRARITY {
        COMMONBOX,
        EPICBOX,
        SUPER_LEGENDBOX
    }

    constructor(
        address aggreggatorAddress,
        address vikingsGoldAddress,
        bytes32 _keyhash,
        address _vrf_coordinator,
        address _linkToken
    ) ERC721("Vikings", "Vks") VRFConsumerBase(_vrf_coordinator, _linkToken) {
        keyHash = _keyhash;
        fee = 0.1 * 10**18;
        priceFeed = AggregatorV3Interface(aggreggatorAddress); // setting price feed
        CommonBoxPriceInUsd = 250 * 10**18; // initialize price of the box
        EpicBoxPriceInUsd = 400 * 10**18; // initialize price of the box
        LegendaryBoxPriceInUsd = 700 * 10**18; // initialize price of the box
        vikingsGold = IERC20(vikingsGoldAddress); // initialize the game Token
        VikingURI[RARITY.COMMON] = "uri"; // initialize URIs
        VikingURI[RARITY.RARE] = "uri";
        VikingURI[RARITY.SUPER_RARE] = "uri";
        VikingURI[RARITY.EPIC] = "uri";
        VikingURI[RARITY.LEGEND] = "uri.LEGEND";
    }

    // Buy Box

    function openMysteryVikingBox() public payable {
        (uint256 commonBoxPrice, , ) = entryFee();
        require(
            msg.value >= commonBoxPrice + 100000,
            "not enough to open the box"
        ); // check the mimum price
        bytes32 requestId = requestRandomness(keyHash, fee); // you can see chainlink documentation
        boxRarityOfRequestId[requestId] = BOXRARITY.COMMONBOX;
        requestIdToOwner[requestId] = msg.sender;
        emit requestToCreatNewViking(requestId, BOXRARITY.COMMONBOX);
    }

    function openEpicVikingBox() public payable {
        (, uint256 epicBoxPrice, ) = entryFee();
        require(
            msg.value >= epicBoxPrice + 100000,
            "not enough to open the box"
        ); // check the mimum price
        bytes32 requestId = requestRandomness(keyHash, fee); // you can see chainlink documentation
        boxRarityOfRequestId[requestId] = BOXRARITY.EPICBOX;
        requestIdToOwner[requestId] = msg.sender;
        emit requestToCreatNewViking(requestId, BOXRARITY.EPICBOX);
    }

    function openLegendaryVikingBox() public payable returns (bytes32) {
        (, , uint256 legendaryBoxPrice) = entryFee();
        require(
            msg.value >= legendaryBoxPrice + 100000,
            "not enough to open the box"
        ); // check the mimum price
        bytes32 requestId = requestRandomness(keyHash, fee); // you can see chainlink documentation
        boxRarityOfRequestId[requestId] = BOXRARITY.SUPER_LEGENDBOX;
        requestIdToOwner[requestId] = msg.sender;
        emit requestToCreatNewViking(requestId, BOXRARITY.SUPER_LEGENDBOX);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 chancePercentage = randomness % 100;
        RARITY newVikingRarity;
        BOXRARITY boxRarity = boxRarityOfRequestId[requestId];
        if (boxRarity == BOXRARITY.COMMONBOX) {
            if (chancePercentage > 41) {
                newVikingRarity = RARITY.COMMON;
            } else if (chancePercentage > 21 && chancePercentage <= 41) {
                newVikingRarity = RARITY.RARE;
            } else if (chancePercentage > 11 && chancePercentage <= 21) {
                newVikingRarity = RARITY.SUPER_RARE;
            } else if (chancePercentage > 4 && chancePercentage <= 11) {
                newVikingRarity = RARITY.EPIC;
            } else if (chancePercentage > 1 && chancePercentage <= 4) {
                newVikingRarity = RARITY.LEGEND;
            } else if (chancePercentage == 1) {
                newVikingRarity = RARITY.SUPER_LEGEND;
            }
        } else if (boxRarity == BOXRARITY.EPICBOX) {
            if (chancePercentage > 64) {
                newVikingRarity = RARITY.COMMON;
            } else if (chancePercentage > 29 && chancePercentage <= 64) {
                newVikingRarity = RARITY.RARE;
            } else if (chancePercentage > 19 && chancePercentage <= 39) {
                newVikingRarity = RARITY.SUPER_RARE;
            } else if (chancePercentage > 4 && chancePercentage <= 19) {
                newVikingRarity = RARITY.EPIC;
            } else if (chancePercentage > 1 && chancePercentage <= 4) {
                newVikingRarity = RARITY.LEGEND;
            } else if (chancePercentage == 1) {
                newVikingRarity = RARITY.SUPER_LEGEND;
            }
        } else if (boxRarity == BOXRARITY.SUPER_LEGENDBOX) {
            if (chancePercentage > 83) {
                newVikingRarity = RARITY.RARE;
            } else if (chancePercentage > 43 && chancePercentage <= 83) {
                newVikingRarity = RARITY.SUPER_RARE;
            } else if (chancePercentage > 13 && chancePercentage <= 43) {
                newVikingRarity = RARITY.EPIC;
            } else if (chancePercentage > 5 && chancePercentage <= 13) {
                newVikingRarity = RARITY.LEGEND;
            } else if (chancePercentage == 1 && chancePercentage <= 5) {
                newVikingRarity = RARITY.SUPER_LEGEND;
            }
        }
        address vikingOwner  = requestIdToOwner[requestId];
        _tokenIds.increment(); // increment the id of the erc721
        uint256 newItemId = _tokenIds.current(); // get Id
        vikingIdOfRequestId[requestId] = newItemId;
        string memory tokenURI = VikingURI[newVikingRarity]; // set rarity # FIX THIS
        vikingRarity[newItemId] = newVikingRarity; // Set the rarity
        _mint(vikingOwner, newItemId); // miniting
        _setTokenURI(newItemId, tokenURI); // set the URI
        vikings.push(newItemId); // add it to array
        emit newVikingBorn(
            newItemId,
            tokenURI,
            msg.sender,
            vikingRarity[newItemId]
        );
    }

    /// @notice get the eteruem price and transfer the minimum price box to Eth
    /// @dev get EntryCost
    /// @return EntryCost the price in etheruem

    function entryFee()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 ethInUsd = uint256(price * 10**10);
        uint256 commonBoxPrice = (CommonBoxPriceInUsd * 10**18) / ethInUsd;
        uint256 epicBoxPrice = (EpicBoxPriceInUsd * 10**18) / ethInUsd;
        uint256 legendaryBoxPrice = (LegendaryBoxPriceInUsd * 10**18) /
            ethInUsd;
        return (commonBoxPrice, epicBoxPrice, legendaryBoxPrice);
    }

    // get the balance of the smart contract

    function getBalance() public view returns (uint256) {
        return (address(this).balance);
    }

    // returns true if the Id given is on the list of tokens
    function isVikingExist(uint256 vikingId) public view returns (bool) {
        for (uint256 i = 0; i < vikings.length; i++) {
            if (vikingId == vikings[i]) {
                return true;
            }
        }
        return false;
    }

    // one fight per day so this function check if it's passed 24h from the last fight ;)
    function isVikingCanFight(uint256 vikingId) public view returns (bool) {
        uint256 vikingLastFight = lastFight[vikingId];
        if (block.timestamp > vikingLastFight + 24 hours) {
            return true;
        } else {
            return false;
        }
    }

    // fight function = > the small game to get VikingsGold
    // You can see the README.md to understand the game

    function fight(uint256 vikingId) public {
        require(isVikingExist(vikingId) == true, "Viking doesn't exist"); // should be true
        require(ownerOf(vikingId) == msg.sender, "This is not your fighter"); // should equal the sender
        require(
            isVikingCanFight(vikingId) == true,
            "Viking is in mode sleep now"
        ); // should be true
        // see README.md
        if (vikingRarity[vikingId] == RARITY.COMMON) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 6;
            emit fightFinished(vikingId, 6);
        } else if (vikingRarity[vikingId] == RARITY.RARE) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 8;
            emit fightFinished(vikingId, 8);
        } else if (vikingRarity[vikingId] == RARITY.SUPER_RARE) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 10;
            emit fightFinished(vikingId, 10);
        } else if (vikingRarity[vikingId] == RARITY.EPIC) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 12;
            emit fightFinished(vikingId, 12);
        } else if (vikingRarity[vikingId] == RARITY.LEGEND) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 25;
            emit fightFinished(vikingId, 25);
        } else if (vikingRarity[vikingId] == RARITY.SUPER_LEGEND) {
            lastFight[vikingId] = block.timestamp;
            playerBalance[msg.sender] += 35;
            emit fightFinished(vikingId, 35);
        }
    }

    //  see README.md
    // if you want to use comment claim5days()
    function claim() public {
        require(
            playerBalance[msg.sender] > 0,
            "You don't have funds or you're not a player"
        );
        uint256 balance = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        address player = payable(msg.sender);
        vikingsGold.transfer(player, balance * 10**18);
        emit claimed(player, balance);
    }

    // 5 to 5 days claim
    // you can claim ones every 5 days
    // if you want to use comment claim()
    // I think I need to check VGD balanceOf contract but I will send it 1M token so no problem
    function isPlayerCanClaim(address player) public view returns (bool) {
        uint256 playerLastClaim = lastClaim[player];
        if (block.timestamp > playerLastClaim + 5 hours) {
            return true;
        } else {
            return false;
        }
    }

    function claim5days() public {
        require(isPlayerCanClaim(msg.sender) == true, "You can't claim now");
        require(
            playerBalance[msg.sender] > 0,
            "You don't have funds or you're not a player"
        );
        lastClaim[msg.sender] = block.timestamp;
        uint256 balance = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        address player = payable(msg.sender);
        vikingsGold.transfer(player, balance * 10**18);
        emit claimed(player, balance);
    }

    // get Link to avoid lock
    function getLinkBack() public onlyOwner {
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }

    // get all contract eth

    function getEth() public onlyOwner {
        address contractOwner = payable(owner());
        uint256 contractBalance = address(this).balance;
        (bool sent, ) = contractOwner.call{value: contractBalance}("");
        require(sent, "fail to send eth");
    }
}
