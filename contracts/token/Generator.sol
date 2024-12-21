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
        uint[4] traits;
        bool[4] hasAccessories;
    }

    uint constant MAX_TRAITS = 4;

    // Updated palettes
    string[20] public capShadowsPalette = ["#5a5353", "#a93b3b", "#3c2420", "#694335", "#784a39", "#e6482e", "#9e6851", "#bf7958", "#cb977f", "#bca296", "#5a3826", "#69442e", "#8f6440", "#b48258", "#cfc6b8", "#949691", "#788079", "#3c5956", "#575b58", "#244341"];
    string[20] public capMidtonesPalette = ["#a05b53", "#e6482e", "#784a39", "#a0938e", "#b47d66", "#e1ae96", "#a38070", "#966c57", "#f47e1b", "#eea160", "#a58258", "#e1d6c7", "#bc9230", "#f4b41b", "#65695e", "#71aa34", "#5aad90", "#48877e", "#97bcbc", "#b6dee1"];
    string[20] public capHighlightsPalette = ["#bf7958", "#cb977f", "#f0e5d4", "#c3baac", "#cfc6b8", "#949691", "#788079", "#3e6253", "#244341", "#dff6f5", "#28ccdf", "#7596cb", "#4d5f96", "#394778", "#827094", "#e182a9", "#cd6093", "#ffaeb6", "#dff6f5", "#b6d53c"];

    string[20] public bodyPalette = ["#a38070", "#966c57", "#5a3826", "#69442e", "#bca296", "#e1ae96", "#f0e5d4", "#c3baac", "#e1d6c7", "#cfc6b8", "#949691", "#3e6253", "#5aad90", "#48877e", "#97bcbc", "#8e478c", "#cd6093", "#e182a9", "#f4b41b", "#65695e"];

    string[20] public ridgesPalette = ["#a58258", "#e1d6c7", "#f0e5d4", "#c3baac", "#cfc6b8", "#dff6f5", "#3e6253", "#575b58", "#949691", "#65695e", "#b6d53c", "#bc9230", "#f4b41b", "#ffcd55", "#b6dee1", "#97acda", "#7596cb", "#4d5f96", "#8e478c", "#e182a9"];

    string[20] public gillsPalette = ["#333333", "#515151", "#6a6a6a", "#3e6253", "#244341", "#575b58", "#3c5956", "#5aad90", "#48877e", "#949691", "#65695e", "#dff6f5", "#97bcbc", "#6b8f8f", "#b6dee1", "#7596cb", "#4d5f96", "#17111e", "#827094", "#564064"];

    string[10] public levelOneBackgrounds = ["#f5f5f5", "#e4ded4", "#bcbcbc", "#ece8e1", "#dcd6cd", "#c3baac", "#f0e5d4", "#dff6f5", "#b6dee1", "#97bcbc"];

    MushroomGifStorage public gifStorage;

    constructor(address gifStorageAddress) {
        gifStorage = MushroomGifStorage(gifStorageAddress);
    }

    function setColors(MushroomData memory data, Rand memory rnd) private view {
        if (data.lvl == 1) {
            data.background = levelOneBackgrounds[rnd.next() % levelOneBackgrounds.length];
        } else if (data.lvl == 2) {
            data.gifBackground = gifStorage.levelTwoGifBackground();
        } else {
            data.background = "#ffffff"; // Default background for other levels
        }

        data.capShadows = capShadowsPalette[rnd.next() % capShadowsPalette.length];
        data.capMidtones = capMidtonesPalette[rnd.next() % capMidtonesPalette.length];
        data.capHighlights = capHighlightsPalette[rnd.next() % capHighlightsPalette.length];
        data.bodyColor = bodyPalette[rnd.next() % bodyPalette.length];
        data.spotsColor = "#eaeaea"; // Fixed color
        data.ridgesColor = ridgesPalette[rnd.next() % ridgesPalette.length];
        data.gillsColor = gillsPalette[rnd.next() % gillsPalette.length];
    }

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            uint baseTrait = rnd.next() % 34; // Level 1: Trait value between 0-33
            if (data.lvl >= 2) {
                baseTrait += rnd.next() % 34; // Level 2: Add 0-33 on top
            }
            if (data.lvl >= 3) {
                baseTrait += rnd.next() % 34; // Level 3: Add another 0-33 on top
            }
            data.traits[i] = baseTrait; // Total can range from 0-99 across all levels
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

        // Add the static overlay (frame.svg)
        svg = string(abi.encodePacked(svg, frameSvg()));

        // Add the mushroom components
        svg = string(
            abi.encodePacked(
                svg,
                capLayerSvg(data.capShadows, data.capMidtones, data.capHighlights),
                bodySvg(data.bodyColor),
                spotsSvg(data.spotsColor),
                ridgesSvg(data.ridgesColor),
                gillsSvg(data.gillsColor)
            )
        );

        // Add trait numbers centered in the 16x16 corners
        svg = string(
            abi.encodePacked(
                svg,
                "<text x='8' y='12' font-size='8' fill='black' text-anchor='middle'>", data.traits[0].toString(), "</text>", // Top-left
                "<text x='56' y='12' font-size='8' fill='black' text-anchor='middle'>", data.traits[1].toString(), "</text>", // Top-right
                "<text x='8' y='60' font-size='8' fill='black' text-anchor='middle'>", data.traits[2].toString(), "</text>", //
                "<text x='56' y='60' font-size='8' fill='black' text-anchor='middle'>", data.traits[3].toString(), "</text>"  // Bottom-right
            )
        );

        // Close the SVG
        svg = string(abi.encodePacked(svg, "</svg>"));

        return svg;
    }

    function frameSvg() private pure returns (string memory) {
        // Reference your frame.svg file
        return "<image href='assets/frame.svg' width='64' height='64' />";
    }

    function capLayerSvg(string memory shadows, string memory midtones, string memory highlights) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='32' cy='32' r='16' fill='", shadows, "' />",
                "<circle cx='32' cy='32' r='14' fill='", midtones, "' />",
                "<circle cx='32' cy='32' r='12' fill='", highlights, "' />"
            )
        );
    }

    function bodySvg(string memory bodyColor) private pure returns (string memory) {
        return string(
            abi.encodePacked("<rect x='26' y='40' width='12' height='20' fill='", bodyColor, "' />")
        );
    }

    function spotsSvg(string memory spotsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='28' cy='30' r='2' fill='", spotsColor, "' />",
                "<circle cx='36' cy='36' r='3' fill='", spotsColor, "' />"
            )
        );
    }

    function ridgesSvg(string memory ridgesColor) private pure returns (string memory) {
        return string(
            abi.encodePacked("<line x1='26' y1='42' x2='38' y2='42' stroke='", ridgesColor, "' stroke-width='2' />")
        );
    }

    function gillsSvg(string memory gillsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked("<path d='M20 40 L44 40 L32 56 Z' fill='", gillsColor, "' />")
        );
    }
}
