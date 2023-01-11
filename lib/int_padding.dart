extension IntPadding on int {
	String padLeft(int amount, [String char = '0']) {
		return toString().padLeft(amount, char);
	}
}