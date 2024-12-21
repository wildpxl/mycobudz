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
    string[4] public capPalette = ["#5a5353", "#3c2420", "#694335", "#784a39"];
    string[4] public bodyPalette = ["#a38070", "#966c57", "#5a3826", "#69442e"];
    string[4] public ridgesPalette = ["#a58258", "#e1d6c7", "#f0e5d4", "#c3baac"];
    string[4] public gillsPalette = ["#333333", "#515151", "#6a6a6a", "#3e6253"];
    string[5] public levelOneBackgrounds = ["#f5f5f5", "#e4ded4", "#bcbcbc", "#ece8e1", "#dcd6cd"];

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

        data.capShadows = capPalette[rnd.next() % capPalette.length];
        data.capMidtones = capPalette[rnd.next() % capPalette.length];
        data.capHighlights = capPalette[rnd.next() % capPalette.length];
        data.bodyColor = bodyPalette[rnd.next() % bodyPalette.length];
        data.spotsColor = "#eaeaea"; // Fixed color
        data.ridgesColor = ridgesPalette[rnd.next() % ridgesPalette.length];
        data.gillsColor = gillsPalette[rnd.next() % gillsPalette.length];
    }

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            data.traits[i] = rnd.next() % 10;
            data.hasAccessories[i] = rnd.next() % 2 == 0;
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
                gillsSvg(data.gillsColor),
                "</svg>"
            )
        );

        return svg;
    }

    function frameSvg() private pure returns (string memory) {
        // Reference your frame.svg file
        return "<image href='assets/frame.svg' width='64' height='64' />";
    }

    function capLayerSvg(string memory shadows, string memory midtones, string memory highlights) private view returns (string memory) {
        return string(abi.encodePacked("<circle cx='32' cy='32' r='16' fill='", shadows, "' />"));
    }

    function bodySvg(string memory bodyColor) private view returns (string memory) {
        return string(abi.encodePacked("<rect x='26' y='40' width='12' height='20' fill='", bodyColor, "' />"));
    }

    function spotsSvg(string memory spotsColor) private view returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='28' cy='30' r='2' fill='", spotsColor, "' />",
                "<circle cx='36' cy='36' r='3' fill='", spotsColor, "' />"
            )
        );
    }

    function ridgesSvg(string memory ridgesColor) private view returns (string memory) {
        return string(
            abi.encodePacked("<line x1='26' y1='42' x2='38' y2='42' stroke='", ridgesColor, "' stroke-width='2' />")
        );
    }

    function gillsSvg(string memory gillsColor) private view returns (string memory) {
        return string(abi.encodePacked("<path d='M20 40 L44 40 L32 56 Z' fill='", gillsColor, "' />"));
    }
}
