import 'package:freezed_annotation/freezed_annotation.dart';

part 'api.model.freezed.dart';
part 'api.model.g.dart';

@freezed
class UpsertResponse with _$UpsertResponse {
  const factory UpsertResponse({required bool success}) = _UpsertResponse;

  factory UpsertResponse.fromJson(Map<String, dynamic> json) =>
      _$UpsertResponseFromJson(json);
}

@freezed
class CreateResponse with _$CreateResponse {
  const factory CreateResponse({required bool success}) = _CreateResponse;

  factory CreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateResponseFromJson(json);
}

@freezed
class UpdateResponse with _$UpdateResponse {
  const factory UpdateResponse({required bool success}) = _UpdateResponse;

  factory UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateResponseFromJson(json);
}

@freezed
class DeleteResponse with _$DeleteResponse {
  const factory DeleteResponse({required bool success}) = _DeleteResponse;

  factory DeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteResponseFromJson(json);
}

/// Error Response
@freezed
class ErrorDetail with _$ErrorDetail {
  const factory ErrorDetail({
    required String field,
    required String message,
    required String type,
  }) = _ErrorDetail;

  factory ErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailFromJson(json);
}

@freezed
class ErrorDetails with _$ErrorDetails {
  const factory ErrorDetails({required List<ErrorDetail> errors}) =
      _ErrorDetails;

  factory ErrorDetails.fromJson(Map<String, dynamic> json) =>
      _$ErrorDetailsFromJson(json);
}

@freezed
class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    int? statusCode,
    String? error,
    required String message,
    String? path,
    String? timestamp,
    String? requestId,
    dynamic data,
    ErrorDetails? details,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
