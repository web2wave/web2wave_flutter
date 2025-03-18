bool isValidUrl(String url) {
  Uri? uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}
