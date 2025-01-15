String replaceOnEmptyOrNull(String? scr, String replacement) {
  if (scr == null || scr.isEmpty) {
    return replacement;
  } else {
    return scr;
  }
}
