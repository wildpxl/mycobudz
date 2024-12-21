function ridgesSvg(string memory ridgesColor) private pure returns (string memory) {
    return string(
        abi.encodePacked(
            "<line x1='20' y1='40' x2='30' y2='50' stroke='", ridgesColor, "' stroke-width='2' />",
            "<line x1='22' y1='42' x2='32' y2='52' stroke='", ridgesColor, "' stroke-width='2' />",
            "<line x1='24' y1='44' x2='34' y2='54' stroke='", ridgesColor, "' stroke-width='2' />"
        )
    );
}
