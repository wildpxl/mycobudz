function spotsSvg(string memory spotsColor) private pure returns (string memory) {
    return string(
        abi.encodePacked(
            "<circle cx='30' cy='20' r='5' fill='", spotsColor, "' />",
            "<circle cx='40' cy='30' r='4' fill='", spotsColor, "' />",
            "<circle cx='25' cy='35' r='6' fill='", spotsColor, "' />"
        )
    );
}
