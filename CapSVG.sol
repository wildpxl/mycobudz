function capLayerSvg(string memory shadows, string memory midtones, string memory highlights) private pure returns (string memory) {
    return string(
        abi.encodePacked(
            "<circle cx='32' cy='32' r='16' fill='", shadows, "' />",
            "<circle cx='32' cy='32' r='12' fill='", midtones, "' />",
            "<circle cx='32' cy='32' r='8' fill='", highlights, "' />"
        )
    );
}
