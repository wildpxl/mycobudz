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
        uint frameIndex; // Frame index for alternating frames
    }

    uint constant MAX_TRAITS = 4;

    // Updated palettes with full color integration
    string[50] public capShadowsPalette = [ /* palette values here */ ];
    string[50] public capMidtonesPalette = [ /* palette values here */ ];
    string[50] public capHighlightsPalette = [ /* palette values here */ ];
    string[10] public framePalette = [ /* frame values here */ ];
    string[10] public levelOneBackgrounds = [ /* levelOne background colors */ ];

    MushroomGifStorage public gifStorage;

    constructor(address gifStorageAddress) {
        gifStorage = MushroomGifStorage(gifStorageAddress);
    }

    function getWeightedIndices() private pure returns (uint[] memory) {
        uint[] memory weightedIndices = new uint[](150);
        uint count = 0;

        for (uint i = 0; i < 50; i++) {
            uint weight = (i < 15 || i >= 35) ? 2 : 5;
            for (uint j = 0; j < weight; j++) {
                weightedIndices[count++] = i;
            }
        }
        return weightedIndices;
    }

    function setColors(MushroomData memory data, Rand memory rnd) private view {
        uint frameCount;

        if (data.lvl == 1) {
            data.background = levelOneBackgrounds[rnd.next() % levelOneBackgrounds.length];
        } else if (data.lvl == 2) {
            uint levelTwoIndex = rnd.next() % 3; // 0, 1, 2
            if (levelTwoIndex == 0) {
                data.gifBackground = gifStorage.levelTwoGifBackground();
                frameCount = 16;
            } else if (levelTwoIndex == 1) {
                data.gifBackground = gifStorage.levelTwoGifBackground2();
                frameCount = 12;
            } else {
                data.gifBackground = gifStorage.levelTwoGifBackground3();
                frameCount = 12;
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
            frameCount = 12;
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
        data.frameIndex = rnd.next() % frameCount;
    }

    function capLayerSvg(string memory shadows, string memory midtones, string memory highlights, uint frameIndex) private pure returns (string memory) {
        string memory frame = (frameIndex % 2 == 0) ? "" : ".2";
        return string(
            abi.encodePacked(
                "<g>",
                "<image href='assets/capshad", frame, ".svg' fill='", shadows, "' />",
                "<image href='assets/capmid", frame, ".svg' fill='", midtones, "' />",
                "<image href='assets/caphi", frame, ".svg' fill='", highlights, "' />",
                "</g>"
            )
        );
    }

    function bodyLayerSvg(string memory bodyColor, string memory ridgesColor, string memory gillsColor, uint frameIndex) private pure returns (string memory) {
        string memory frame = (frameIndex % 2 == 0) ? "" : ".2";
        return string(
            abi.encodePacked(
                "<g>",
                "<image href='assets/body", frame, ".svg' fill='", bodyColor, "' />",
                "<image href='assets/ridhi", frame, ".svg' fill='", ridgesColor, "' />",
                "<image href='assets/gmid", frame, ".svg' fill='", gillsColor, "' />",
                "</g>"
            )
        );
    }

    function spotsLayerSvg(string memory spotsColor, uint frameIndex) private pure returns (string memory) {
        string memory frame = (frameIndex % 2 == 0) ? "" : ".2";
        return string(
            abi.encodePacked(
                "<g>",
                "<image href='assets/spots", frame, ".svg' fill='", spotsColor, "' />",
                "</g>"
            )
        );
    }

    function getSvg(SeedData calldata seed_data) external view returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";

        // Add the background logic
        if (data.lvl == 2 || data.lvl == 3) {
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
                capLayerSvg(data.capShadows, data.capMidtones, data.capHighlights, data.frameIndex),
                bodyLayerSvg(data.bodyColor, data.ridgesColor, data.gillsColor, data.frameIndex),
                spotsLayerSvg(data.spotsColor, data.frameIndex)
            )
        );

        svg = string(abi.encodePacked(svg, "</svg>"));
        return svg;
    }
}
