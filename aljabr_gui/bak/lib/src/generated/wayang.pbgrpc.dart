// This is a generated file - do not edit.
//
// Generated from wayang.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'wayang.pb.dart' as $0;

export 'wayang.pb.dart';

@$pb.GrpcServiceName('wayang.ProjectService')
class ProjectServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ProjectServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Project> createProject(
    $0.CreateProjectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createProject, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListProjectsResponse> listProjects(
    $0.ListProjectsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProjects, request, options: options);
  }

  $grpc.ResponseFuture<$0.Session> createSession(
    $0.CreateSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListSessionsResponse> listSessions(
    $0.ListSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  // method descriptors

  static final _$createProject =
      $grpc.ClientMethod<$0.CreateProjectRequest, $0.Project>(
          '/wayang.ProjectService/CreateProject',
          ($0.CreateProjectRequest value) => value.writeToBuffer(),
          $0.Project.fromBuffer);
  static final _$listProjects =
      $grpc.ClientMethod<$0.ListProjectsRequest, $0.ListProjectsResponse>(
          '/wayang.ProjectService/ListProjects',
          ($0.ListProjectsRequest value) => value.writeToBuffer(),
          $0.ListProjectsResponse.fromBuffer);
  static final _$createSession =
      $grpc.ClientMethod<$0.CreateSessionRequest, $0.Session>(
          '/wayang.ProjectService/CreateSession',
          ($0.CreateSessionRequest value) => value.writeToBuffer(),
          $0.Session.fromBuffer);
  static final _$listSessions =
      $grpc.ClientMethod<$0.ListSessionsRequest, $0.ListSessionsResponse>(
          '/wayang.ProjectService/ListSessions',
          ($0.ListSessionsRequest value) => value.writeToBuffer(),
          $0.ListSessionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('wayang.ProjectService')
abstract class ProjectServiceBase extends $grpc.Service {
  $core.String get $name => 'wayang.ProjectService';

  ProjectServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateProjectRequest, $0.Project>(
        'CreateProject',
        createProject_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateProjectRequest.fromBuffer(value),
        ($0.Project value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListProjectsRequest, $0.ListProjectsResponse>(
            'ListProjects',
            listProjects_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListProjectsRequest.fromBuffer(value),
            ($0.ListProjectsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateSessionRequest, $0.Session>(
        'CreateSession',
        createSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateSessionRequest.fromBuffer(value),
        ($0.Session value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListSessionsRequest, $0.ListSessionsResponse>(
            'ListSessions',
            listSessions_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListSessionsRequest.fromBuffer(value),
            ($0.ListSessionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Project> createProject_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateProjectRequest> $request) async {
    return createProject($call, await $request);
  }

  $async.Future<$0.Project> createProject(
      $grpc.ServiceCall call, $0.CreateProjectRequest request);

  $async.Future<$0.ListProjectsResponse> listProjects_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListProjectsRequest> $request) async {
    return listProjects($call, await $request);
  }

  $async.Future<$0.ListProjectsResponse> listProjects(
      $grpc.ServiceCall call, $0.ListProjectsRequest request);

  $async.Future<$0.Session> createSession_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateSessionRequest> $request) async {
    return createSession($call, await $request);
  }

  $async.Future<$0.Session> createSession(
      $grpc.ServiceCall call, $0.CreateSessionRequest request);

  $async.Future<$0.ListSessionsResponse> listSessions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListSessionsRequest> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$0.ListSessionsResponse> listSessions(
      $grpc.ServiceCall call, $0.ListSessionsRequest request);
}

@$pb.GrpcServiceName('wayang.ApiKeyService')
class ApiKeyServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ApiKeyServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CreateApiKeyResponse> createApiKey(
    $0.CreateApiKeyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createApiKey, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListApiKeysResponse> listApiKeys(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listApiKeys, request, options: options);
  }

  // method descriptors

  static final _$createApiKey =
      $grpc.ClientMethod<$0.CreateApiKeyRequest, $0.CreateApiKeyResponse>(
          '/wayang.ApiKeyService/CreateApiKey',
          ($0.CreateApiKeyRequest value) => value.writeToBuffer(),
          $0.CreateApiKeyResponse.fromBuffer);
  static final _$listApiKeys =
      $grpc.ClientMethod<$0.Empty, $0.ListApiKeysResponse>(
          '/wayang.ApiKeyService/ListApiKeys',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ListApiKeysResponse.fromBuffer);
}

@$pb.GrpcServiceName('wayang.ApiKeyService')
abstract class ApiKeyServiceBase extends $grpc.Service {
  $core.String get $name => 'wayang.ApiKeyService';

  ApiKeyServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.CreateApiKeyRequest, $0.CreateApiKeyResponse>(
            'CreateApiKey',
            createApiKey_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateApiKeyRequest.fromBuffer(value),
            ($0.CreateApiKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListApiKeysResponse>(
        'ListApiKeys',
        listApiKeys_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListApiKeysResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateApiKeyResponse> createApiKey_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateApiKeyRequest> $request) async {
    return createApiKey($call, await $request);
  }

  $async.Future<$0.CreateApiKeyResponse> createApiKey(
      $grpc.ServiceCall call, $0.CreateApiKeyRequest request);

  $async.Future<$0.ListApiKeysResponse> listApiKeys_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listApiKeys($call, await $request);
  }

  $async.Future<$0.ListApiKeysResponse> listApiKeys(
      $grpc.ServiceCall call, $0.Empty request);
}
