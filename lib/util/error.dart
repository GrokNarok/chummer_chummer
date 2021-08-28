enum ErrorCodes {
  parseFail,
  fileIO,

  testError,
  unknownError,
}

enum ErrorLevels {
  info,
  warning,
  error,
  fatal,
}

/// Generic error class that contains information about an error.
///
/// This is used by [ErrorOr<T>] class to pass relevant information from the
/// function where an error occurred to the calling code that can handle
/// the error as appropriate.
class ErrorData {
  final ErrorCodes code;
  final ErrorLevels level;
  final String msg;

  ErrorData(this.code, this.level, this.msg);
}

/// A wrapper class for function return values that may be a valid value or an error.
///
/// This is our primary way of handling errors and should be used instead of
/// throwing exceptions wherever possible.
///
/// Wrapping the return of a function:
/// ```dart
/// ErrorOr<String> getTextFromNet() {
///   // Get string...
///   if (allIsGood) {
///     return ErrorOr(validString)
///   } else {
///     return ErrorOr.error(ErrorData(ErrorCodes.allIsNotGood, ErrorLevels.error, "All is not good."));
///   }
/// }
/// ```
/// Checking the return:
/// ```dart
/// final result = getTextFromNet();
/// if (result.isError) {
///   showErrorPopup(result.error); // Handle error.
/// } else {
///   importantText = result.value;
/// }
/// ```
/// Also see ApiService and code that uses ApiService for usage example.
class ErrorOr<T> {
  final ErrorData? _error;
  final T? _value;
  bool _checkedError = false;

  ErrorOr.error(ErrorData error)
      : this._error = error,
        this._value = null;
  ErrorOr(T value)
      : this._error = null,
        this._value = value;

  bool get isError {
    _checkedError = true;
    return _error != null;
  }

  bool get isNotError => !isError;

  T get value {
    assert(_checkedError, "Accessing the value without checking if it's an error first.");
    assert(_error == null, "Accessing the value that doesn't exist.");
    return _value!;
  }

  ErrorData get error {
    assert(_checkedError, "Accessing the error without checking if it's an error first.");
    assert(_error != null, "Accessing the error that doesn't exist.");
    return _error!;
  }
}
