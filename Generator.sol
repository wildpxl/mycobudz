// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Erc20.sol";
import "./PoolCreatableErc20i.sol";
import "./Generator.sol";

contract MushroomGenerator is Generator {
    using Strings for uint;

    struct MushroomData {
        uint lvl;
        string background;      // Background color
        string capShadows;      // Shadow for Cap
        string capMidtones;     // Midtone for Cap
        string capHighlights;   // Highlight for Cap
        string bodyColor;       // Body color
        string spotsColor;      // Spots color
        string ridgesColor;     // Ridges color
        string gillsColor;      // Gills color
        uint[4] traits;         // Strength, Dexterity, Luck, Wisdom
        bool[4] hasAccessories; // Accessory flags for each trait
    }

    uint constant MAX_TRAITS = 4;

    // Assign colors based on Grey Palette
    function setColors(MushroomData memory data, Rand memory rnd) private pure {
        // Assign colors for each part based on your grey palette
        data.capShadows = selectColor(rnd, ["#2f2f2f", "#484848"]);
        data.capMidtones = selectColor(rnd, ["#515151", "#6a6a6a"]);
        data.capHighlights = "#888888"; // Fixed highlight color
        data.bodyColor = selectColor(rnd, ["#737373", "#959595", "#bbbbbb"]);
        data.spotsColor = "#eaeaea"; // Fixed highlight for spots
        data.ridgesColor = selectColor(rnd, ["#737373", "#959595", "#bbbbbb"]);
        data.gillsColor = selectColor(rnd, ["#333333", "#515151"]);
    }

    // Randomly select a color from a palette
    function selectColor(Rand memory rnd, string[] memory colors) private pure returns (string memory) {
        uint index = rnd.next() % colors.length;
        return colors[index];
    }

    // Get Mushroom with color and accessory logic
    function getMushroom(SeedData calldata seed_data) external view returns (MushroomData memory) {
        Rand memory rnd = Rand(seed_data.seed, 0, seed_data.extra);
        MushroomData memory data;
        data.lvl = rnd.lvl();
        setColors(data, rnd);
        setTraits(data, rnd);
        return data;
    }

    // Generate the SVG with layers for highlights, midtones, and shadows
    function getSvg(SeedData calldata seed_data) external view returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";

        // Add cap layers
        svg = string(
            abi.encodePacked(
                svg,
                capLayerSvg(data.capShadows, data.capMidtones, data.capHighlights)
            )
        );

        // Add body
        svg = string(abi.encodePacked(svg, bodySvg(data.bodyColor)));

        // Add spots and ridges
        svg = string(abi.encodePacked(svg, spotsSvg(data.spotsColor)));
        svg = string(abi.encodePacked(svg, ridgesSvg(data.ridgesColor)));

        // Add gills
        svg = string(abi.encodePacked(svg, gillsSvg(data.gillsColor)));

        // Add traits and accessories
        svg = string(abi.encodePacked(svg, traitsSvg(data)));
        svg = string(abi.encodePacked(svg, accessoriesSvg(data)));

        return string(abi.encodePacked(svg, "</svg>"));
    }

    // SVG Layer for Cap
    function capLayerSvg(
        string memory shadows,
        string memory midtones,
        string memory highlights
    ) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='32' cy='32' r='16' fill='", shadows, "' />", // Shadows
                "<circle cx='32' cy='32' r='12' fill='", midtones, "' />", // Midtones
                "<circle cx='32' cy='32' r='8' fill='", highlights, "' />"  // Highlights
            )
        );
    }

    // SVG for Body
    function bodySvg(string memory bodyColor) private pure returns (string memory) {
        return string(
            abi.encodePacked("<rect x='26' y='40' width='12' height='20' fill='", bodyColor, "' />")
        );
    }

    // SVG for Spots
    function spotsSvg(string memory spotsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='28' cy='30' r='2' fill='", spotsColor, "' />",
                "<circle cx='36' cy='36' r='3' fill='", spotsColor, "' />"
            )
        );
    }

    // SVG for Ridges
    function ridgesSvg(string memory ridgesColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<line x1='26' y1='42' x2='38' y2='42' stroke='", ridgesColor, "' stroke-width='2' />"
            )
        );
    }

    // SVG for Gills
    function gillsSvg(string memory gillsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<path d='M20 40 L44 40 L32 56 Z' fill='", gillsColor, "' />"
            )
        );
    }

    // SVG for Traits
    function traitsSvg(MushroomData memory data) private pure returns (string memory) {
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

    // SVG for Accessories
    function accessoriesSvg(MushroomData memory data) private pure returns (string memory) {
        string memory accessorySvg;
        for (uint i = 0; i < MAX_TRAITS; i++) {
            if (data.hasAccessories[i]) {
                accessorySvg = string(
                    abi.encodePacked(
                        accessorySvg,
                        "<image href='https://your-storage-path/accessory",
                        i.toString(),
                        ".png' x='",
                        i == 0 || i == 2 ? "4" : "48",
                        "' y='",
                        i < 2 ? "4" : "48",
                        "' width='8' height='8'/>"
                    )
                );
            }
        }
        return accessorySvg;
    }
}
