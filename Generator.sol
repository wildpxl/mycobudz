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
        string groundColor; // Ground color
        uint cap;
        string capColor;
        uint capDesign;
        string capDesignColor;
        uint[4] traits; // Strength, Dexterity, Luck, Wisdom
        bool[4] hasAccessories; // Accessory flags for each trait
    }

    uint constant MAX_TRAITS = 4;

    // Updated token thresholds
    uint constant seedLevel1 = 1_000_000;
    uint constant seedLevel2 = 5_000_000;
    uint constant seedLevel3 = 10_000_000;

    // Random ranges for traits based on levels
    function getTraitValue(
        uint currentValue,
        uint lvl,
        Rand memory rnd
    ) internal pure returns (uint) {
        uint increment = rnd.next() % 34; // Increment between 0-33
        return currentValue + increment;
    }

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            uint newValue = getTraitValue(data.traits[i], data.lvl, rnd);
            data.traits[i] = newValue;
            if (data.lvl >= 2 && newValue > 30) {
                data.hasAccessories[i] = true; // Accessory appears for this trait
            }
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
        setCap(data, rnd);
        setTraits(data, rnd);
        return data;
    }

    function setCap(MushroomData memory data, Rand memory rnd) private view {
        data.cap = rnd.next() % capLevelCounts[data.lvl.to_lvl_1()];
        data.capColor = mushroomColors(data.lvl.to_lvl_1())[rnd.next() % 10];
        data.capDesign = rnd.next() % 9; // Nine possible designs
        data.capDesignColor = mushroomColors(data.lvl.to_lvl_1())[rnd.next() % 10];
    }

    function accessoriesSvg(MushroomData memory data) private pure returns (string memory) {
        string memory accessorySvg;

        // For each trait, add an accessory if it exists
        for (uint i = 0; i < MAX_TRAITS; i++) {
            if (data.hasAccessories[i]) {
                string memory accessory = string(
                    abi.encodePacked(
                        "<image href='https://your-storage-path/accessory",
                        i.toString(),
                        ".png' x='",
                        i == 0 || i == 2 ? "4" : "48", // Left for Strength, Luck; Right for Dexterity, Wisdom
                        "' y='",
                        i < 2 ? "4" : "48", // Top for Strength, Dexterity; Bottom for Luck, Wisdom
                        "' width='8' height='8'/>"
                    )
                );
                accessorySvg = string(abi.encodePacked(accessorySvg, accessory));
            }
        }

        return accessorySvg;
    }

    function groundSvg(
        MushroomData memory data
    ) private pure returns (string memory) {
        // Full canvas ground for Level 1
        if (data.lvl == 1) {
            return string(
                abi.encodePacked("<rect x='0' y='0' width='64' height='64' fill='", data.groundColor, "'/>")
            );
        }
        // No ground for Levels 2 and 3
        return "";
    }

    function getSvg(
        SeedData calldata seed_data
    ) external view returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";

        // Render ground or background
        svg = string(abi.encodePacked(svg, groundSvg(data)));

        // Render cap and other elements
        svg = string(abi.encodePacked(svg, capSvg(data)));
        svg = string(abi.encodePacked(svg, accessoriesSvg(data))); // Add accessories
        svg = string(abi.encodePacked(svg, traitsSvg(data))); // Add traits as text
        return string(abi.encodePacked(svg, "</svg>"));
    }

    function traitsSvg(MushroomData memory data) private pure returns (string memory) {
        // Trait rendering logic
        string memory traits;
        for (uint i = 0; i < MAX_TRAITS; i++) {
            traits = string(
                abi.encodePacked(
                    traits,
                    "<text x='",
                    i < 2 ? "8" : "48",
                    "' y='",
                    i % 2 == 0 ? "12" : "60",
                    "' font-size='8' fill='black' font-family='monospace' text-anchor='",
                    i < 2 ? "start" : "end",
                    "'>",
                    data.traits[i].toString(),
                    "</text>"
                )
            );
        }
        return traits;
    }

    function capSvg(
        MushroomData memory data
    ) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='32' cy='32' r='16' fill='", data.capColor, "' stroke='black' stroke-width='2' />"
            )
        );
    }
}
