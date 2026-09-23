/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'basket_error.dart' as _ix8f32lp;

/// The one exception every endpoint throws, so the client can switch on
/// `error` instead of matching strings. Never put anything sensitive in here:
/// serializable exceptions are sent to the client in full.
abstract class OpenBasketException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  OpenBasketException._({
    required this.error,
    required this.message,
    this.triesLeft,
  });

  factory OpenBasketException({
    required _ix8f32lp.BasketError error,
    required String message,
    int? triesLeft,
  }) = _OpenBasketExceptionImpl;

  factory OpenBasketException.fromJson(Map<String, dynamic> jsonSerialization) {
    return OpenBasketException(
      error: _ix8f32lp.BasketError.fromJson(
        (jsonSerialization['error'] as String),
      ),
      message: jsonSerialization['message'] as String,
      triesLeft: jsonSerialization['triesLeft'] as int?,
    );
  }

  _ix8f32lp.BasketError error;

  /// English, safe to show. Built from `app_en.arb` on the client where the
  /// wording matters; this is the fallback.
  String message;

  /// How many more tries a failed join has left before the account has to
  /// wait (ADR-045). Null for every other error.
  int? triesLeft;

  /// Returns a shallow copy of this [OpenBasketException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  OpenBasketException copyWith({
    _ix8f32lp.BasketError? error,
    String? message,
    int? triesLeft,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OpenBasketException',
      'error': error.toJson(),
      'message': message,
      if (triesLeft != null) 'triesLeft': triesLeft,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OpenBasketException',
      'error': error.toJson(),
      'message': message,
      if (triesLeft != null) 'triesLeft': triesLeft,
    };
  }

  @override
  String toString() {
    return 'OpenBasketException(error: $error, message: $message, triesLeft: $triesLeft)';
  }
}

class _Undefined {}

class _OpenBasketExceptionImpl extends OpenBasketException {
  _OpenBasketExceptionImpl({
    required _ix8f32lp.BasketError error,
    required String message,
    int? triesLeft,
  }) : super._(
         error: error,
         message: message,
         triesLeft: triesLeft,
       );

  /// Returns a shallow copy of this [OpenBasketException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  OpenBasketException copyWith({
    _ix8f32lp.BasketError? error,
    String? message,
    Object? triesLeft = _Undefined,
  }) {
    return OpenBasketException(
      error: error ?? this.error,
      message: message ?? this.message,
      triesLeft: triesLeft is int? ? triesLeft : this.triesLeft,
    );
  }
}
