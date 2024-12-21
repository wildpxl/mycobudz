function bodySvg(string memory bodyColor) private pure returns (string memory) {
    return string(
        abi.encodePacked(
            "<rect x='20' y='30' width='24' height='24' fill='", bodyColor, "' />",
            "<rect x='22' y='32' width='20' height='20' fill='", adjustColor(bodyColor, 1), "' />",
            "<rect x='24' y='34' width='16' height='16' fill='", adjustColor(bodyColor, 2), "' />"
        )
    );
}
