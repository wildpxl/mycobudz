function capSvg(MushroomData memory data) private pure returns (string memory) {
    // Highlights
    string memory highlight = string(
        abi.encodePacked("<path fill='", getCapColor(data.lvl, 0), "' d='M0,0 L10,10 ... Z' />")
    );
    // Mid-tones
    string memory midTone = string(
        abi.encodePacked("<path fill='", getCapColor(data.lvl, 1), "' d='M10,10 L20,20 ... Z' />")
    );
    // Shadows
    string memory shadow = string(
        abi.encodePacked("<path fill='", getCapColor(data.lvl, 2), "' d='M20,20 L30,30 ... Z' />")
    );

    return string(abi.encodePacked(highlight, midTone, shadow));
}
