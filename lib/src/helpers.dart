bool isValidUrl(String url) {
  Uri? uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.hasAuthority;
}

String prepareUrl(String baseUrl, int topOffset, int bottomOffset) {
    final uri = Uri.parse(baseUrl);
    
    final params = Map<String, String>.from(uri.queryParameters);
    
    params['webview_flutter'] = '1';
    params['top_padding'] = topOffset.toString();
    params['bottom_padding'] = bottomOffset.toString();
    
    return uri.replace(queryParameters: params).toString();
}
