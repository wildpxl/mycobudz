// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Erc20.sol";
import "./PoolCreatableErc20i.sol";
import "./Generator.sol";
import "./MushroomGifStorage.sol";

contract MushroomGenerator is Generator {
    using Strings for uint;

    struct MushroomData {
        uint lvl;
        string background; // For static backgrounds
        string gifBackground; // For GIF backgrounds
        string capShadows;
        string capMidtones;
        string capHighlights;
        string bodyColor;
        string spotsColor;
        string ridgesColor;
        string gillsColor;
        string frameOverlay; // Dynamic frame overlay
        uint[4] traits;
        bool[4] hasAccessories;
    }

    uint constant MAX_TRAITS = 4;

    // Updated palettes with full color integration
    string[50] public capShadowsPalette = [
        "#5a5353", "#3c2420", "#5a3826", "#69442e", "#a93b3b", "#a05b53", 
        "#694335", "#784a39", "#966c57", "#bf7958", "#b47d66", "#cb977f", 
        "#bca296", "#949691", "#575b58", "#3e6253", "#3c5956", "#244341", 
        "#5aad90", "#48877e", "#397b44", "#65695e", "#788079", "#4d5f96", 
        "#394778", "#564064", "#5e3643", "#302c2e", "#000000", "#0f2d27", 
        "#2d181d", "#17111e", "#3c2420", "#5a5353", "#7a444a", "#827094", 
        "#8e478c", "#cd6093", "#e182a9", "#f47e1b", "#f4b41b", "#e6482e", 
        "#bc9230", "#a58258", "#a0938e", "#e1ae96", "#dff6f5", "#b6d53c"
    ];
    
    string[50] public capMidtonesPalette = [
        "#a93b3b", "#a05b53", "#bf7958", "#b47d66", "#cb977f", "#966c57", 
        "#784a39", "#694335", "#e6482e", "#f47e1b", "#eea160", "#bc9230", 
        "#f4b41b", "#a58258", "#a38070", "#a0938e", "#cfc6b8", "#e1d6c7", 
        "#c3baac", "#bca296", "#b6d53c", "#71aa34", "#5aad90", "#48877e", 
        "#6b8f8f", "#97bcbc", "#7596cb", "#97acda", "#827094", "#8e478c", 
        "#cd6093", "#e182a9", "#7d7071", "#7a444a", "#e1ae96", "#dff6f5", 
        "#cfc6b8", "#3e6253", "#3c5956", "#244341", "#5aad90", "#48877e", 
        "#b6dee1", "#dff6f5", "#e1d6c7", "#c3baac", "#4d5f96", "#394778"
    ];

    string[50] public capHighlightsPalette = [
        "#f47e1b", "#f4b41b", "#eea160", "#e1ae96", "#e6482e", "#bc9230", 
        "#bf7958", "#b47d66", "#cb977f", "#f0e5d4", "#e1d6c7", "#cfc6b8", 
        "#c3baac", "#dff6f5", "#b6dee1", "#28ccdf", "#7596cb", "#97acda", 
        "#4d5f96", "#394778", "#564064", "#5e3643", "#cd6093", "#e182a9", 
        "#827094", "#97bcbc", "#65695e", "#788079", "#949691", "#7d7071", 
        "#7a444a", "#f0e5d4", "#b6d53c", "#71aa34", "#5aad90", "#48877e", 
        "#b6d53c", "#dff6f5", "#f4b41b", "#bc9230", "#e1ae96", "#8e478c", 
        "#cd6093", "#394778", "#f4b41b", "#e1ae96", "#e1d6c7", "#c3baac"
    ];

    string[10] public framePalette = [
        "<image href='assets/frame1.svg' width='64' height='64' />",
        "<image href='assets/frame2.svg' width='64' height='64' />",
        "<image href='assets/frame3.svg' width='64' height='64' />",
        "<image href='assets/frame4.svg' width='64' height='64' />",
        "<image href='assets/frame5.svg' width='64' height='64' />",
        "<image href='assets/frame6.svg' width='64' height='64' />",
        "<image href='assets/frame7.svg' width='64' height='64' />",
        "<image href='assets/frame8.svg' width='64' height='64' />",
        "<image href='assets/frame9.svg' width='64' height='64' />",
        "<image href='assets/frame10.svg' width='64' height='64' />"
    ];

    string[10] public levelOneBackgrounds = [
        "#f5f5f5", "#e4ded4", "#bcbcbc", "#ece8e1", "#dcd6cd", "#c3baac", 
        "#f0e5d4", "#dff6f5", "#b6dee1", "#97bcbc"
    ];

    MushroomGifStorage public gifStorage;

    constructor(address gifStorageAddress) {
        gifStorage = MushroomGifStorage(gifStorageAddress);
    }

    function getWeightedIndices() private pure returns (uint[] memory) {
        uint[] memory weightedIndices = new uint[](150); // Increased size for color diversity
        uint count = 0;

        for (uint i = 0; i < 50; i++) {
            uint weight = (i < 15 || i >= 35) ? 2 : 5; // Lighter/darker tones weighted less, midtones weighted more
            for (uint j = 0; j < weight; j++) {
                weightedIndices[count++] = i;
            }
        }
        return weightedIndices;
    }

    function setColors(MushroomData memory data, Rand memory rnd) private view {
    if (data.lvl == 1) {
        data.background = levelOneBackgrounds[rnd.next() % levelOneBackgrounds.length];
    } else if (data.lvl == 2) {
        uint levelTwoIndex = rnd.next() % 3; // 0, 1, 2
        if (levelTwoIndex == 0) {
            data.gifBackground = gifStorage.levelTwoGifBackground();
        } else if (levelTwoIndex == 1) {
            data.gifBackground = gifStorage.levelTwoGifBackground2();
        } else {
            data.gifBackground = gifStorage.levelTwoGifBackground3();
        }
    } else if (data.lvl == 3) {
        uint levelThreeIndex = rnd.next() % 5; // 0 through 4
        if (levelThreeIndex == 0) {
            data.gifBackground = gifStorage.levelThreeGifBackground1();
        } else if (levelThreeIndex == 1) {
            data.gifBackground = gifStorage.levelThreeGifBackground2();
        } else if (levelThreeIndex == 2) {
            data.gifBackground = gifStorage.levelThreeGifBackground3();
        } else if (levelThreeIndex == 3) {
            data.gifBackground = gifStorage.levelThreeGifBackground4();
        } else {
            data.gifBackground = gifStorage.levelThreeGifBackground5();
        }
    } else {
        data.background = "#ffffff"; // Default background for other levels
    }

    uint[] memory weightedIndices = getWeightedIndices();
    uint weightedIndex = weightedIndices[rnd.next() % weightedIndices.length];

    data.capShadows = capShadowsPalette[weightedIndex];
    data.capMidtones = capMidtonesPalette[weightedIndex];
    data.capHighlights = capHighlightsPalette[weightedIndex];

    data.bodyColor = capMidtonesPalette[(weightedIndex + 5) % 50];
    data.spotsColor = capHighlightsPalette[(weightedIndex + 10) % 50];
    data.ridgesColor = capShadowsPalette[(weightedIndex + 15) % 50];
    data.gillsColor = capMidtonesPalette[(weightedIndex + 20) % 50];

    data.frameOverlay = framePalette[rnd.next() % framePalette.length];
}

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            uint baseTrait = rnd.next() % 50; // Trait value between 0-49
            if (data.lvl >= 2) {
                baseTrait += rnd.next() % 50; // Add 0-49 on top for Level 2
            }
            if (data.lvl >= 3) {
                baseTrait += rnd.next() % 50; // Add another 0-49 on top for Level 3
            }
            data.traits[i] = baseTrait; // Total can range from 0-149 across all levels
            data.hasAccessories[i] = rnd.next() % 2 == 0; // Random boolean for accessories
        }
    }

    function getMushroom(SeedData calldata seed_data) external view returns (MushroomData memory) {
        Rand memory rnd = Rand(seed_data.seed, 0, seed_data.extra);
        MushroomData memory data;
        data.lvl = rnd.lvl();
        setColors(data, rnd);
        setTraits(data, rnd);
        return data;
    }

    function getSvg(SeedData calldata seed_data) external view returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";

        // Add the background logic
        if (data.lvl == 2) {
            svg = string(
                abi.encodePacked(
                    svg,
                    "<image href='", data.gifBackground, "' width='64' height='64'/>"
                )
            );
        } else {
            svg = string(
                abi.encodePacked(
                    svg,
                    "<rect width='64' height='64' fill='", data.background, "' />"
                )
            );
        }

        // Add the dynamic overlay (frame.svg)
        svg = string(abi.encodePacked(svg, data.frameOverlay));

        // Add the mushroom components
        svg = string(
            abi.encodePacked(
                svg,
                capLayerSvg(data.capShadows, data.capMidtones, data.capHighlights
                ),
                bodyLayerSvg(data.bodyColor, data.ridgesColor, data.gillsColor),
                spotsLayerSvg(data.spotsColor)
            )
        );

        svg = string(abi.encodePacked(svg, "</svg>"));
        return svg;
    }

    function capLayerSvg(string memory shadows, string memory midtones, string memory highlights) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<g>",
                "<path fill='", shadows, "' d='M12 20 ...'/>", // Example shadow path
                "<path fill='", midtones, "' d='M14 18 ...'/>", // Example midtone path
                "<path fill='", highlights, "' d='M16 16 ...'/>", // Example highlight path
                "</g>"
            )
        );
    }

    function bodyLayerSvg(string memory bodyColor, string memory ridgesColor, string memory gillsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<g>",
                "<path fill='", bodyColor, "' d='M20 24 ...'/>", // Example body path
                "<path fill='", ridgesColor, "' d='M22 26 ...'/>", // Example ridges path
                "<path fill='", gillsColor, "' d='M24 28 ...'/>", // Example gills path
                "</g>"
            )
        );
    }

    function spotsLayerSvg(string memory spotsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<g>",
                "<circle fill='", spotsColor, "' cx='20' cy='20' r='2'/>", // Example spot
                "<circle fill='", spotsColor, "' cx='24' cy='24' r='3'/>", // Another example spot
                "</g>"
            )
        );
    }

    function getTraits(SeedData calldata seed_data) external view returns (uint[4] memory, bool[4] memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        return (data.traits, data.hasAccessories);
    }
}
