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

  $grpc.ResponseFuture<$0.Session> forkSession(
    $0.ForkSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forkSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteSessionResponse> deleteSession(
    $0.DeleteSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.IndexWorkspaceResponse> indexWorkspace(
    $0.IndexWorkspaceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$indexWorkspace, request, options: options);
  }

  $grpc.ResponseFuture<$0.Session> updateSessionStatus(
    $0.UpdateSessionStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSessionStatus, request, options: options);
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
  static final _$forkSession =
      $grpc.ClientMethod<$0.ForkSessionRequest, $0.Session>(
          '/wayang.ProjectService/ForkSession',
          ($0.ForkSessionRequest value) => value.writeToBuffer(),
          $0.Session.fromBuffer);
  static final _$deleteSession =
      $grpc.ClientMethod<$0.DeleteSessionRequest, $0.DeleteSessionResponse>(
          '/wayang.ProjectService/DeleteSession',
          ($0.DeleteSessionRequest value) => value.writeToBuffer(),
          $0.DeleteSessionResponse.fromBuffer);
  static final _$indexWorkspace =
      $grpc.ClientMethod<$0.IndexWorkspaceRequest, $0.IndexWorkspaceResponse>(
          '/wayang.ProjectService/IndexWorkspace',
          ($0.IndexWorkspaceRequest value) => value.writeToBuffer(),
          $0.IndexWorkspaceResponse.fromBuffer);
  static final _$updateSessionStatus =
      $grpc.ClientMethod<$0.UpdateSessionStatusRequest, $0.Session>(
          '/wayang.ProjectService/UpdateSessionStatus',
          ($0.UpdateSessionStatusRequest value) => value.writeToBuffer(),
          $0.Session.fromBuffer);
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
    $addMethod($grpc.ServiceMethod<$0.ForkSessionRequest, $0.Session>(
        'ForkSession',
        forkSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ForkSessionRequest.fromBuffer(value),
        ($0.Session value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteSessionRequest, $0.DeleteSessionResponse>(
            'DeleteSession',
            deleteSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteSessionRequest.fromBuffer(value),
            ($0.DeleteSessionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.IndexWorkspaceRequest,
            $0.IndexWorkspaceResponse>(
        'IndexWorkspace',
        indexWorkspace_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.IndexWorkspaceRequest.fromBuffer(value),
        ($0.IndexWorkspaceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateSessionStatusRequest, $0.Session>(
        'UpdateSessionStatus',
        updateSessionStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateSessionStatusRequest.fromBuffer(value),
        ($0.Session value) => value.writeToBuffer()));
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

  $async.Future<$0.Session> forkSession_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ForkSessionRequest> $request) async {
    return forkSession($call, await $request);
  }

  $async.Future<$0.Session> forkSession(
      $grpc.ServiceCall call, $0.ForkSessionRequest request);

  $async.Future<$0.DeleteSessionResponse> deleteSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteSessionRequest> $request) async {
    return deleteSession($call, await $request);
  }

  $async.Future<$0.DeleteSessionResponse> deleteSession(
      $grpc.ServiceCall call, $0.DeleteSessionRequest request);

  $async.Future<$0.IndexWorkspaceResponse> indexWorkspace_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.IndexWorkspaceRequest> $request) async {
    return indexWorkspace($call, await $request);
  }

  $async.Future<$0.IndexWorkspaceResponse> indexWorkspace(
      $grpc.ServiceCall call, $0.IndexWorkspaceRequest request);

  $async.Future<$0.Session> updateSessionStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateSessionStatusRequest> $request) async {
    return updateSessionStatus($call, await $request);
  }

  $async.Future<$0.Session> updateSessionStatus(
      $grpc.ServiceCall call, $0.UpdateSessionStatusRequest request);
}

@$pb.GrpcServiceName('wayang.TaskService')
class TaskServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TaskServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Task> createTask(
    $0.CreateTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTasksResponse> listTasks(
    $0.ListTasksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTasks, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> updateTaskStatus(
    $0.UpdateTaskStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateTaskStatus, request, options: options);
  }

  // method descriptors

  static final _$createTask = $grpc.ClientMethod<$0.CreateTaskRequest, $0.Task>(
      '/wayang.TaskService/CreateTask',
      ($0.CreateTaskRequest value) => value.writeToBuffer(),
      $0.Task.fromBuffer);
  static final _$listTasks =
      $grpc.ClientMethod<$0.ListTasksRequest, $0.ListTasksResponse>(
          '/wayang.TaskService/ListTasks',
          ($0.ListTasksRequest value) => value.writeToBuffer(),
          $0.ListTasksResponse.fromBuffer);
  static final _$updateTaskStatus =
      $grpc.ClientMethod<$0.UpdateTaskStatusRequest, $0.Task>(
          '/wayang.TaskService/UpdateTaskStatus',
          ($0.UpdateTaskStatusRequest value) => value.writeToBuffer(),
          $0.Task.fromBuffer);
}

@$pb.GrpcServiceName('wayang.TaskService')
abstract class TaskServiceBase extends $grpc.Service {
  $core.String get $name => 'wayang.TaskService';

  TaskServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateTaskRequest, $0.Task>(
        'CreateTask',
        createTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateTaskRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTasksRequest, $0.ListTasksResponse>(
        'ListTasks',
        listTasks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTasksRequest.fromBuffer(value),
        ($0.ListTasksResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateTaskStatusRequest, $0.Task>(
        'UpdateTaskStatus',
        updateTaskStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateTaskStatusRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
  }

  $async.Future<$0.Task> createTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTaskRequest> $request) async {
    return createTask($call, await $request);
  }

  $async.Future<$0.Task> createTask(
      $grpc.ServiceCall call, $0.CreateTaskRequest request);

  $async.Future<$0.ListTasksResponse> listTasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListTasksRequest> $request) async {
    return listTasks($call, await $request);
  }

  $async.Future<$0.ListTasksResponse> listTasks(
      $grpc.ServiceCall call, $0.ListTasksRequest request);

  $async.Future<$0.Task> updateTaskStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateTaskStatusRequest> $request) async {
    return updateTaskStatus($call, await $request);
  }

  $async.Future<$0.Task> updateTaskStatus(
      $grpc.ServiceCall call, $0.UpdateTaskStatusRequest request);
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

  $grpc.ResponseFuture<$0.Empty> revokeApiKey(
    $0.ApiKey request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeApiKey, request, options: options);
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
  static final _$revokeApiKey = $grpc.ClientMethod<$0.ApiKey, $0.Empty>(
      '/wayang.ApiKeyService/RevokeApiKey',
      ($0.ApiKey value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
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
    $addMethod($grpc.ServiceMethod<$0.ApiKey, $0.Empty>(
        'RevokeApiKey',
        revokeApiKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ApiKey.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
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

  $async.Future<$0.Empty> revokeApiKey_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ApiKey> $request) async {
    return revokeApiKey($call, await $request);
  }

  $async.Future<$0.Empty> revokeApiKey(
      $grpc.ServiceCall call, $0.ApiKey request);
}

@$pb.GrpcServiceName('wayang.ChatService')
class ChatServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ChatServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ListChatMessagesResponse> listMessages(
    $0.ListChatMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMessages, request, options: options);
  }

  $grpc.ResponseFuture<$0.ChatMessage> addMessage(
    $0.AddChatMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMessage, request, options: options);
  }

  $grpc.ResponseStream<$0.ChatMessage> observeSession(
    $0.ObserveSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$observeSession, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.RunAgentEvent> runAgent(
    $0.RunAgentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$runAgent, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$listMessages = $grpc.ClientMethod<$0.ListChatMessagesRequest,
          $0.ListChatMessagesResponse>(
      '/wayang.ChatService/ListMessages',
      ($0.ListChatMessagesRequest value) => value.writeToBuffer(),
      $0.ListChatMessagesResponse.fromBuffer);
  static final _$addMessage =
      $grpc.ClientMethod<$0.AddChatMessageRequest, $0.ChatMessage>(
          '/wayang.ChatService/AddMessage',
          ($0.AddChatMessageRequest value) => value.writeToBuffer(),
          $0.ChatMessage.fromBuffer);
  static final _$observeSession =
      $grpc.ClientMethod<$0.ObserveSessionRequest, $0.ChatMessage>(
          '/wayang.ChatService/ObserveSession',
          ($0.ObserveSessionRequest value) => value.writeToBuffer(),
          $0.ChatMessage.fromBuffer);
  static final _$runAgent =
      $grpc.ClientMethod<$0.RunAgentRequest, $0.RunAgentEvent>(
          '/wayang.ChatService/RunAgent',
          ($0.RunAgentRequest value) => value.writeToBuffer(),
          $0.RunAgentEvent.fromBuffer);
}

@$pb.GrpcServiceName('wayang.ChatService')
abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'wayang.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListChatMessagesRequest,
            $0.ListChatMessagesResponse>(
        'ListMessages',
        listMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListChatMessagesRequest.fromBuffer(value),
        ($0.ListChatMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddChatMessageRequest, $0.ChatMessage>(
        'AddMessage',
        addMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddChatMessageRequest.fromBuffer(value),
        ($0.ChatMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ObserveSessionRequest, $0.ChatMessage>(
        'ObserveSession',
        observeSession_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ObserveSessionRequest.fromBuffer(value),
        ($0.ChatMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RunAgentRequest, $0.RunAgentEvent>(
        'RunAgent',
        runAgent_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.RunAgentRequest.fromBuffer(value),
        ($0.RunAgentEvent value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListChatMessagesResponse> listMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListChatMessagesRequest> $request) async {
    return listMessages($call, await $request);
  }

  $async.Future<$0.ListChatMessagesResponse> listMessages(
      $grpc.ServiceCall call, $0.ListChatMessagesRequest request);

  $async.Future<$0.ChatMessage> addMessage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddChatMessageRequest> $request) async {
    return addMessage($call, await $request);
  }

  $async.Future<$0.ChatMessage> addMessage(
      $grpc.ServiceCall call, $0.AddChatMessageRequest request);

  $async.Stream<$0.ChatMessage> observeSession_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ObserveSessionRequest> $request) async* {
    yield* observeSession($call, await $request);
  }

  $async.Stream<$0.ChatMessage> observeSession(
      $grpc.ServiceCall call, $0.ObserveSessionRequest request);

  $async.Stream<$0.RunAgentEvent> runAgent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RunAgentRequest> $request) async* {
    yield* runAgent($call, await $request);
  }

  $async.Stream<$0.RunAgentEvent> runAgent(
      $grpc.ServiceCall call, $0.RunAgentRequest request);
}

@$pb.GrpcServiceName('wayang.SdkService')
class SdkServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SdkServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ListProvidersResponse> listProviders(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProviders, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListModelsResponse> listModels(
    $0.ListModelsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listModels, request, options: options);
  }

  // method descriptors

  static final _$listProviders =
      $grpc.ClientMethod<$0.Empty, $0.ListProvidersResponse>(
          '/wayang.SdkService/ListProviders',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ListProvidersResponse.fromBuffer);
  static final _$listModels =
      $grpc.ClientMethod<$0.ListModelsRequest, $0.ListModelsResponse>(
          '/wayang.SdkService/ListModels',
          ($0.ListModelsRequest value) => value.writeToBuffer(),
          $0.ListModelsResponse.fromBuffer);
}

@$pb.GrpcServiceName('wayang.SdkService')
abstract class SdkServiceBase extends $grpc.Service {
  $core.String get $name => 'wayang.SdkService';

  SdkServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListProvidersResponse>(
        'ListProviders',
        listProviders_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListProvidersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListModelsRequest, $0.ListModelsResponse>(
        'ListModels',
        listModels_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListModelsRequest.fromBuffer(value),
        ($0.ListModelsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListProvidersResponse> listProviders_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listProviders($call, await $request);
  }

  $async.Future<$0.ListProvidersResponse> listProviders(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ListModelsResponse> listModels_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListModelsRequest> $request) async {
    return listModels($call, await $request);
  }

  $async.Future<$0.ListModelsResponse> listModels(
      $grpc.ServiceCall call, $0.ListModelsRequest request);
}
