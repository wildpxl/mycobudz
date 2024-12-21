function gillsSvg(string memory gillsColor) private pure returns (string memory) {
    return string(
        abi.encodePacked(
            "<line x1='28' y1='40' x2='36' y2='40' stroke='", gillsColor, "' stroke-width='1' />",
            "<line x1='28' y1='42' x2='36' y2='42' stroke='", gillsColor, "' stroke-width='1' />",
            "<line x1='28' y1='44' x2='36' y2='44' stroke='", gillsColor, "' stroke-width='1' />"
        )
    );
}
