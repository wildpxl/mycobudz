// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Erc20.sol"; // Your provided ERC20 implementation
import "./PoolCreatableErc20i.sol"; // Pool interface for ERC20i
import "./Generator.sol"; // Base Generator for traits and SVG logic

contract MushroomGenerator is Generator {
    using Strings for uint;

    struct MushroomData {
        uint lvl;
        string background;
        uint ground;
        string groundColor;
        uint stem;
        string stemColor;
        uint cap;
        string capColor;
        uint capDesign;
        string capDesignColor;
        uint[4] traits; // Strength, Dexterity, Luck, Wisdom
        bool veil; // Whether the mushroom has a veil
    }

    uint constant MAX_TRAITS = 4;

    // Updated token thresholds
    uint constant seedLevel1 = 1_000_000;
    uint constant seedLevel2 = 5_000_000;
    uint constant seedLevel3 = 10_000_000;
    uint constant seedLevel4 = 15_000_000; // Optional future level
    uint constant seedLevel5 = 20_000_000; // Optional future level

    // Random ranges for traits based on levels
    function getTraitValue(uint lvl, Rand memory rnd) internal pure returns (uint) {
        if (lvl == 1) return rnd.next() % 34; // Range 0-33
        if (lvl == 2) return (rnd.next() % 33) + 34; // Range 34-66
        return (rnd.next() % 33) + 67; // Range 67-99
    }

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            data.traits[i] = getTraitValue(data.lvl, rnd);
        }
    }

    function getMushroom(
        SeedData calldata seed_data
    ) external view returns (MushroomData memory) {
        Rand memory rnd = Rand(seed_data.seed, 0, seed_data.extra);
        MushroomData memory data;
        data.lvl = rnd.lvl();
        setBackground(data, rnd);
        setGround(data, rnd);
        setStem(data, rnd);
        setCap(data, rnd);
        setTraits(data, rnd);
        data.veil = rnd.next() % 2 == 0; // 50% chance to have a veil
        return data;
    }

    function setCap(MushroomData memory data, Rand memory rnd) private view {
        data.cap = rnd.next() % capLevelCounts[data.lvl.to_lvl_1()];
        data.capColor = mushroomColors(data.lvl.to_lvl_1())[rnd.next() % 10];
        data.capDesign = rnd.next() % 9; // Nine possible designs
        data.capDesignColor = mushroomColors(data.lvl.to_lvl_1())[rnd.next() % 10];
    }

    function traitsSvg(MushroomData memory data) private pure returns (string memory) {
        // Top-left: Strength
        string memory topLeft = string(
            abi.encodePacked(
                "<text x='8' y='12' font-size='8' fill='black' font-family='monospace'>",
                data.traits[0].toString(),
                "</text>"
            )
        );
        // Top-right: Dexterity
        string memory topRight = string(
            abi.encodePacked(
                "<text x='48' y='12' font-size='8' fill='black' font-family='monospace' text-anchor='end'>",
                data.traits[1].toString(),
                "</text>"
            )
        );
        // Bottom-left: Luck
        string memory bottomLeft = string(
            abi.encodePacked(
                "<text x='8' y='60' font-size='8' fill='black' font-family='monospace'>",
                data.traits[2].toString(),
                "</text>"
            )
        );
        // Bottom-right: Wisdom
        string memory bottomRight = string(
            abi.encodePacked(
                "<text x='48' y='60' font-size='8' fill='black' font-family='monospace' text-anchor='end'>",
                data.traits[3].toString(),
                "</text>"
            )
        );

        return string(abi.encodePacked(topLeft, topRight, bottomLeft, bottomRight));
    }

    function veilSvg() private pure returns (string memory) {
        return
            "<rect x='10' y='50' width='15' height='5' fill='white' stroke='black' />";
    }

    function getSvg(
        SeedData calldata seed_data
    ) external view returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";
        svg = string(abi.encodePacked(svg, backgroundSvg(data)));
        svg = string(abi.encodePacked(svg, groundSvg(data)));
        svg = string(abi.encodePacked(svg, stemSvg(data)));
        svg = string(abi.encodePacked(svg, capSvg(data)));
        if (data.veil) {
            svg = string(abi.encodePacked(svg, veilSvg()));
        }
        svg = string(abi.encodePacked(svg, traitsSvg(data))); // Add traits as text
        return string(abi.encodePacked(svg, "</svg>"));
    }
}
