// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Erc20.sol";
import "./PoolCreatableErc20i.sol";
import "./Generator.sol";

// MushroomGenerator.sol

contract MushroomGenerator is Generator {
    using Strings for uint;

    struct MushroomData {
        uint lvl;
        string background;
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

    function setColors(MushroomData memory data, Rand memory rnd) private pure {
        // Cap colors
        data.capShadows = selectColor(rnd, ["#5a5353", "#3c2420", "#694335", "#784a39"]); // Darker tones
        data.capMidtones = selectColor(rnd, ["#a0938e", "#9e6851", "#b47d66", "#cb977f"]); // Medium tones
        data.capHighlights = selectColor(rnd, ["#e1ae96", "#f0e5d4", "#cfc6b8"]);         // Lighter tones

        // Body colors
        data.bodyColor = selectColor(rnd, ["#a38070", "#966c57", "#5a3826", "#69442e"]);

        // Spots color (fixed as per your specification)
        data.spotsColor = "#eaeaea";

        // Ridges colors
        data.ridgesColor = selectColor(rnd, ["#a58258", "#e1d6c7", "#f0e5d4", "#c3baac"]);

        // Gills colors
        data.gillsColor = selectColor(rnd, ["#333333", "#515151", "#6a6a6a", "#3e6253"]);
    }

    function selectColor(Rand memory rnd, string[] memory colors) private pure returns (string memory) {
        uint index = rnd.next() % colors.length;
        return colors[index];
    }

    function setTraits(MushroomData memory data, Rand memory rnd) private pure {
        for (uint i = 0; i < MAX_TRAITS; i++) {
            data.traits[i] = rnd.next() % 10;
            data.hasAccessories[i] = rnd.next() % 2 == 0;
        }
    }

    function getMushroom(SeedData calldata seed_data) external pure returns (MushroomData memory) {
        Rand memory rnd = Rand(seed_data.seed, 0, seed_data.extra);
        MushroomData memory data;
        data.lvl = rnd.lvl();
        setColors(data, rnd);
        setTraits(data, rnd);
        return data;
    }

    function getSvg(SeedData calldata seed_data) external pure returns (string memory) {
        MushroomData memory data = this.getMushroom(seed_data);
        string memory svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'>";

        svg = string(
            abi.encodePacked(
                svg,
                capLayerSvg(data.capShadows, data.capMidtones, data.capHighlights),
                bodySvg(data.bodyColor),
                spotsSvg(data.spotsColor),
                ridgesSvg(data.ridgesColor),
                gillsSvg(data.gillsColor),
                traitsSvg(data),
                accessoriesSvg(data),
                "</svg>"
            )
        );

        return svg;
    }

    function capLayerSvg(string memory shadows, string memory midtones, string memory highlights) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<circle cx='32' cy='32' r='16' fill='", shadows, "' />",
                "<circle cx='32' cy='32' r='12' fill='", midtones, "' />",
                "<circle cx='32' cy='32' r='8' fill='", highlights, "' />"
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
            abi.encodePacked(
                "<line x1='26' y1='42' x2='38' y2='42' stroke='", ridgesColor, "' stroke-width='2' />"
            )
        );
    }

    function gillsSvg(string memory gillsColor) private pure returns (string memory) {
        return string(
            abi.encodePacked("<path d='M20 40 L44 40 L32 56 Z' fill='", gillsColor, "' />")
        );
    }

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

// Fungi.sol

contract Fungi is ERC20, ReentrancyGuard {
    constructor() ERC20("Wild", "WILD") {
        _mint(msg.sender, 1_420_000_000 * 10 ** decimals());
    }

    function generateMushroomSvg(uint seed, uint extraSeed) external view returns (string memory) {
        SeedData memory seedData = SeedData(seed, extraSeed);
        MushroomData memory data = MushroomGenerator(address(this)).getMushroom(seedData);
        return MushroomGenerator(address(this)).getSvg(seedData);
    }
}
