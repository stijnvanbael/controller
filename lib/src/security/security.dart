abstract class Security {
  bool verify(Map<String, String> headers, List<String> requiredClaims);
}
