// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Erc20.sol";
import "./Generator.sol";

contract Fungi is ERC20, Generator, ReentrancyGuard {
    constructor() ERC20("Fungi", "FUNGI") {
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
    }

    function generateMushroomSvg(uint seed, uint extraSeed) external view returns (string memory) {
        SeedData memory seedData = SeedData(seed, extraSeed);
        MushroomData memory data = this.generateMushroom(seedData);
        return this.generateSvg(data);
    }
}
