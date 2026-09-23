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
import 'package:serverpod/serverpod.dart' as _is;

abstract class ClosingSoonFutureCallRemindModel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ClosingSoonFutureCallRemindModel._({required this.basketId});

  factory ClosingSoonFutureCallRemindModel({required int basketId}) =
      _ClosingSoonFutureCallRemindModelImpl;

  factory ClosingSoonFutureCallRemindModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ClosingSoonFutureCallRemindModel(
      basketId: jsonSerialization['basketId'] as int,
    );
  }

  int basketId;

  /// Returns a shallow copy of this [ClosingSoonFutureCallRemindModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ClosingSoonFutureCallRemindModel copyWith({int? basketId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClosingSoonFutureCallRemindModel',
      'basketId': basketId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ClosingSoonFutureCallRemindModelImpl
    extends ClosingSoonFutureCallRemindModel {
  _ClosingSoonFutureCallRemindModelImpl({required int basketId})
    : super._(basketId: basketId);

  /// Returns a shallow copy of this [ClosingSoonFutureCallRemindModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ClosingSoonFutureCallRemindModel copyWith({int? basketId}) {
    return ClosingSoonFutureCallRemindModel(
      basketId: basketId ?? this.basketId,
    );
  }
}
