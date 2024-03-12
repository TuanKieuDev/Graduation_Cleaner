enum ErrorCode {
  internalError(500, "Internal error");

  const ErrorCode(this.code, this.description);
  final int code;
  final String description;
}
