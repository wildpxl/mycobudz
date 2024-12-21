const fs = require('fs');
const gifData = fs.readFileSync('levelTwoGifBackground.txt', 'utf8');

// Replace placeholder with the Base64 string
const contractContent = `
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract MushroomGifStorage {
    string public constant levelTwoGifBackground = "data:image/gif;base64,${gifData}";
}
`;

fs.writeFileSync('MushroomGifStorage.sol', contractContent);
