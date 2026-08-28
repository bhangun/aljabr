// This is a generated file - do not edit.
//
// Generated from wayang.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use projectDescriptor instead')
const Project$json = {
  '1': 'Project',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'base_path', '3': 5, '4': 1, '5': 9, '10': 'basePath'},
    {'1': 'metadata', '3': 6, '4': 1, '5': 9, '10': 'metadata'},
    {'1': 'archived', '3': 7, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `Project`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectDescriptor = $convert.base64Decode(
    'CgdQcm9qZWN0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElkEh'
    'IKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEhsK'
    'CWJhc2VfcGF0aBgFIAEoCVIIYmFzZVBhdGgSGgoIbWV0YWRhdGEYBiABKAlSCG1ldGFkYXRhEh'
    'oKCGFyY2hpdmVkGAcgASgIUghhcmNoaXZlZA==');

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
    {'1': 'metadata', '3': 6, '4': 1, '5': 9, '10': 'metadata'},
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEg4KAmlkGAEgASgJUgJpZBIdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SW'
    'QSGwoJdGVuYW50X2lkGAMgASgJUgh0ZW5hbnRJZBISCgRuYW1lGAQgASgJUgRuYW1lEhYKBnN0'
    'YXR1cxgFIAEoCVIGc3RhdHVzEhoKCG1ldGFkYXRhGAYgASgJUghtZXRhZGF0YQ==');

@$core.Deprecated('Use apiKeyDescriptor instead')
const ApiKey$json = {
  '1': 'ApiKey',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'key_prefix', '3': 4, '4': 1, '5': 9, '10': 'keyPrefix'},
    {'1': 'enabled', '3': 5, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `ApiKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List apiKeyDescriptor = $convert.base64Decode(
    'CgZBcGlLZXkSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW50SWQSEg'
    'oEbmFtZRgDIAEoCVIEbmFtZRIdCgprZXlfcHJlZml4GAQgASgJUglrZXlQcmVmaXgSGAoHZW5h'
    'YmxlZBgFIAEoCFIHZW5hYmxlZA==');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use createProjectRequestDescriptor instead')
const CreateProjectRequest$json = {
  '1': 'CreateProjectRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'base_path', '3': 3, '4': 1, '5': 9, '10': 'basePath'},
  ],
};

/// Descriptor for `CreateProjectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProjectRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQcm9qZWN0UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAIgASgJUgtkZXNjcmlwdGlvbhIbCgliYXNlX3BhdGgYAyABKAlSCGJhc2VQYXRo');

@$core.Deprecated('Use listProjectsRequestDescriptor instead')
const ListProjectsRequest$json = {
  '1': 'ListProjectsRequest',
  '2': [
    {'1': 'include_archived', '3': 1, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `ListProjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProjectsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0UHJvamVjdHNSZXF1ZXN0EikKEGluY2x1ZGVfYXJjaGl2ZWQYASABKAhSD2luY2x1ZG'
    'VBcmNoaXZlZA==');

@$core.Deprecated('Use listProjectsResponseDescriptor instead')
const ListProjectsResponse$json = {
  '1': 'ListProjectsResponse',
  '2': [
    {
      '1': 'projects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.Project',
      '10': 'projects'
    },
  ],
};

/// Descriptor for `ListProjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProjectsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0UHJvamVjdHNSZXNwb25zZRIrCghwcm9qZWN0cxgBIAMoCzIPLndheWFuZy5Qcm9qZW'
    'N0Ughwcm9qZWN0cw==');

@$core.Deprecated('Use createSessionRequestDescriptor instead')
const CreateSessionRequest$json = {
  '1': 'CreateSessionRequest',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVTZXNzaW9uUmVxdWVzdBIdCgpwcm9qZWN0X2lkGAEgASgJUglwcm9qZWN0SWQSEg'
    'oEbmFtZRgCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use listSessionsRequestDescriptor instead')
const ListSessionsRequest$json = {
  '1': 'ListSessionsRequest',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `ListSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0U2Vzc2lvbnNSZXF1ZXN0Eh0KCnByb2plY3RfaWQYASABKAlSCXByb2plY3RJZA==');

@$core.Deprecated('Use listSessionsResponseDescriptor instead')
const ListSessionsResponse$json = {
  '1': 'ListSessionsResponse',
  '2': [
    {
      '1': 'sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.Session',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `ListSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0U2Vzc2lvbnNSZXNwb25zZRIrCghzZXNzaW9ucxgBIAMoCzIPLndheWFuZy5TZXNzaW'
    '9uUghzZXNzaW9ucw==');

@$core.Deprecated('Use forkSessionRequestDescriptor instead')
const ForkSessionRequest$json = {
  '1': 'ForkSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `ForkSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forkSessionRequestDescriptor = $convert.base64Decode(
    'ChJGb3JrU2Vzc2lvblJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh0KCm'
    '1lc3NhZ2VfaWQYAiABKAlSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use deleteSessionRequestDescriptor instead')
const DeleteSessionRequest$json = {
  '1': 'DeleteSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `DeleteSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSessionRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVTZXNzaW9uUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQ=');

@$core.Deprecated('Use deleteSessionResponseDescriptor instead')
const DeleteSessionResponse$json = {
  '1': 'DeleteSessionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSessionResponseDescriptor =
    $convert.base64Decode(
        'ChVEZWxldGVTZXNzaW9uUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use indexWorkspaceRequestDescriptor instead')
const IndexWorkspaceRequest$json = {
  '1': 'IndexWorkspaceRequest',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'workspace_path', '3': 2, '4': 1, '5': 9, '10': 'workspacePath'},
  ],
};

/// Descriptor for `IndexWorkspaceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indexWorkspaceRequestDescriptor = $convert.base64Decode(
    'ChVJbmRleFdvcmtzcGFjZVJlcXVlc3QSHQoKcHJvamVjdF9pZBgBIAEoCVIJcHJvamVjdElkEi'
    'UKDndvcmtzcGFjZV9wYXRoGAIgASgJUg13b3Jrc3BhY2VQYXRo');

@$core.Deprecated('Use indexWorkspaceResponseDescriptor instead')
const IndexWorkspaceResponse$json = {
  '1': 'IndexWorkspaceResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'files_indexed', '3': 2, '4': 1, '5': 5, '10': 'filesIndexed'},
    {'1': 'symbols_indexed', '3': 3, '4': 1, '5': 5, '10': 'symbolsIndexed'},
    {
      '1': 'dependencies_indexed',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'dependenciesIndexed'
    },
    {'1': 'duration_ms', '3': 5, '4': 1, '5': 3, '10': 'durationMs'},
    {'1': 'repository_hash', '3': 6, '4': 1, '5': 9, '10': 'repositoryHash'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `IndexWorkspaceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List indexWorkspaceResponseDescriptor = $convert.base64Decode(
    'ChZJbmRleFdvcmtzcGFjZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSIwoNZm'
    'lsZXNfaW5kZXhlZBgCIAEoBVIMZmlsZXNJbmRleGVkEicKD3N5bWJvbHNfaW5kZXhlZBgDIAEo'
    'BVIOc3ltYm9sc0luZGV4ZWQSMQoUZGVwZW5kZW5jaWVzX2luZGV4ZWQYBCABKAVSE2RlcGVuZG'
    'VuY2llc0luZGV4ZWQSHwoLZHVyYXRpb25fbXMYBSABKANSCmR1cmF0aW9uTXMSJwoPcmVwb3Np'
    'dG9yeV9oYXNoGAYgASgJUg5yZXBvc2l0b3J5SGFzaBIUCgVlcnJvchgHIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use updateSessionStatusRequestDescriptor instead')
const UpdateSessionStatusRequest$json = {
  '1': 'UpdateSessionStatusRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `UpdateSessionStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSessionStatusRequestDescriptor =
    $convert.base64Decode(
        'ChpVcGRhdGVTZXNzaW9uU3RhdHVzUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW'
        '9uSWQSFgoGc3RhdHVzGAIgASgJUgZzdGF0dXM=');

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'task_type', '3': 4, '4': 1, '5': 9, '10': 'taskType'},
    {'1': 'payload', '3': 5, '4': 1, '5': 9, '10': 'payload'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'priority', '3': 7, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'attempts', '3': 8, '4': 1, '5': 5, '10': 'attempts'},
    {'1': 'max_attempts', '3': 9, '4': 1, '5': 5, '10': 'maxAttempts'},
    {'1': 'error', '3': 10, '4': 1, '5': 9, '10': 'error'},
    {'1': 'scheduled_at', '3': 11, '4': 1, '5': 9, '10': 'scheduledAt'},
    {'1': 'started_at', '3': 12, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'completed_at', '3': 13, '4': 1, '5': 9, '10': 'completedAt'},
    {'1': 'created_at', '3': 14, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgJUgJpZBIdCgpzZXNzaW9uX2lkGAIgASgJUglzZXNzaW9uSWQSGw'
    'oJdGVuYW50X2lkGAMgASgJUgh0ZW5hbnRJZBIbCgl0YXNrX3R5cGUYBCABKAlSCHRhc2tUeXBl'
    'EhgKB3BheWxvYWQYBSABKAlSB3BheWxvYWQSFgoGc3RhdHVzGAYgASgJUgZzdGF0dXMSGgoIcH'
    'Jpb3JpdHkYByABKAVSCHByaW9yaXR5EhoKCGF0dGVtcHRzGAggASgFUghhdHRlbXB0cxIhCgxt'
    'YXhfYXR0ZW1wdHMYCSABKAVSC21heEF0dGVtcHRzEhQKBWVycm9yGAogASgJUgVlcnJvchIhCg'
    'xzY2hlZHVsZWRfYXQYCyABKAlSC3NjaGVkdWxlZEF0Eh0KCnN0YXJ0ZWRfYXQYDCABKAlSCXN0'
    'YXJ0ZWRBdBIhCgxjb21wbGV0ZWRfYXQYDSABKAlSC2NvbXBsZXRlZEF0Eh0KCmNyZWF0ZWRfYX'
    'QYDiABKAlSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use createTaskRequestDescriptor instead')
const CreateTaskRequest$json = {
  '1': 'CreateTaskRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'task_type', '3': 2, '4': 1, '5': 9, '10': 'taskType'},
    {'1': 'payload', '3': 3, '4': 1, '5': 9, '10': 'payload'},
    {'1': 'priority', '3': 4, '4': 1, '5': 5, '10': 'priority'},
  ],
};

/// Descriptor for `CreateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUYXNrUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSGwoJdG'
    'Fza190eXBlGAIgASgJUgh0YXNrVHlwZRIYCgdwYXlsb2FkGAMgASgJUgdwYXlsb2FkEhoKCHBy'
    'aW9yaXR5GAQgASgFUghwcmlvcml0eQ==');

@$core.Deprecated('Use listTasksRequestDescriptor instead')
const ListTasksRequest$json = {
  '1': 'ListTasksRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `ListTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VGFza3NSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZA==');

@$core.Deprecated('Use listTasksResponseDescriptor instead')
const ListTasksResponse$json = {
  '1': 'ListTasksResponse',
  '2': [
    {'1': 'tasks', '3': 1, '4': 3, '5': 11, '6': '.wayang.Task', '10': 'tasks'},
  ],
};

/// Descriptor for `ListTasksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0VGFza3NSZXNwb25zZRIiCgV0YXNrcxgBIAMoCzIMLndheWFuZy5UYXNrUgV0YXNrcw'
    '==');

@$core.Deprecated('Use updateTaskStatusRequestDescriptor instead')
const UpdateTaskStatusRequest$json = {
  '1': 'UpdateTaskStatusRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `UpdateTaskStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTaskStatusRequestDescriptor =
    $convert.base64Decode(
        'ChdVcGRhdGVUYXNrU3RhdHVzUmVxdWVzdBIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSFgoGc3'
        'RhdHVzGAIgASgJUgZzdGF0dXMSFAoFZXJyb3IYAyABKAlSBWVycm9y');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'role', '3': 4, '4': 1, '5': 9, '10': 'role'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'tool_calls', '3': 6, '4': 1, '5': 9, '10': 'toolCalls'},
    {'1': 'tokens', '3': 7, '4': 1, '5': 5, '10': 'tokens'},
    {'1': 'model', '3': 8, '4': 1, '5': 9, '10': 'model'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRIOCgJpZBgBIAEoCVICaWQSHQoKc2Vzc2lvbl9pZBgCIAEoCVIJc2Vzc2'
    'lvbklkEhsKCXRlbmFudF9pZBgDIAEoCVIIdGVuYW50SWQSEgoEcm9sZRgEIAEoCVIEcm9sZRIY'
    'Cgdjb250ZW50GAUgASgJUgdjb250ZW50Eh0KCnRvb2xfY2FsbHMYBiABKAlSCXRvb2xDYWxscx'
    'IWCgZ0b2tlbnMYByABKAVSBnRva2VucxIUCgVtb2RlbBgIIAEoCVIFbW9kZWwSHQoKY3JlYXRl'
    'ZF9hdBgJIAEoCVIJY3JlYXRlZEF0');

@$core.Deprecated('Use listChatMessagesRequestDescriptor instead')
const ListChatMessagesRequest$json = {
  '1': 'ListChatMessagesRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `ListChatMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listChatMessagesRequestDescriptor =
    $convert.base64Decode(
        'ChdMaXN0Q2hhdE1lc3NhZ2VzUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSW'
        'QSFAoFbGltaXQYAiABKAVSBWxpbWl0EhYKBm9mZnNldBgDIAEoBVIGb2Zmc2V0');

@$core.Deprecated('Use listChatMessagesResponseDescriptor instead')
const ListChatMessagesResponse$json = {
  '1': 'ListChatMessagesResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.ChatMessage',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `ListChatMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listChatMessagesResponseDescriptor =
    $convert.base64Decode(
        'ChhMaXN0Q2hhdE1lc3NhZ2VzUmVzcG9uc2USLwoIbWVzc2FnZXMYASADKAsyEy53YXlhbmcuQ2'
        'hhdE1lc3NhZ2VSCG1lc3NhZ2Vz');

@$core.Deprecated('Use addChatMessageRequestDescriptor instead')
const AddChatMessageRequest$json = {
  '1': 'AddChatMessageRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '10': 'role'},
    {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
    {'1': 'tool_calls', '3': 4, '4': 1, '5': 9, '10': 'toolCalls'},
    {'1': 'tokens', '3': 5, '4': 1, '5': 5, '10': 'tokens'},
    {'1': 'model', '3': 6, '4': 1, '5': 9, '10': 'model'},
  ],
};

/// Descriptor for `AddChatMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addChatMessageRequestDescriptor = $convert.base64Decode(
    'ChVBZGRDaGF0TWVzc2FnZVJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh'
    'IKBHJvbGUYAiABKAlSBHJvbGUSGAoHY29udGVudBgDIAEoCVIHY29udGVudBIdCgp0b29sX2Nh'
    'bGxzGAQgASgJUgl0b29sQ2FsbHMSFgoGdG9rZW5zGAUgASgFUgZ0b2tlbnMSFAoFbW9kZWwYBi'
    'ABKAlSBW1vZGVs');

@$core.Deprecated('Use observeSessionRequestDescriptor instead')
const ObserveSessionRequest$json = {
  '1': 'ObserveSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `ObserveSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List observeSessionRequestDescriptor = $convert.base64Decode(
    'ChVPYnNlcnZlU2Vzc2lvblJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklk');

@$core.Deprecated('Use createApiKeyRequestDescriptor instead')
const CreateApiKeyRequest$json = {
  '1': 'CreateApiKeyRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateApiKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createApiKeyRequestDescriptor = $convert
    .base64Decode('ChNDcmVhdGVBcGlLZXlSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use createApiKeyResponseDescriptor instead')
const CreateApiKeyResponse$json = {
  '1': 'CreateApiKeyResponse',
  '2': [
    {
      '1': 'api_key',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wayang.ApiKey',
      '10': 'apiKey'
    },
    {'1': 'plain_text_key', '3': 2, '4': 1, '5': 9, '10': 'plainTextKey'},
  ],
};

/// Descriptor for `CreateApiKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createApiKeyResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVBcGlLZXlSZXNwb25zZRInCgdhcGlfa2V5GAEgASgLMg4ud2F5YW5nLkFwaUtleV'
    'IGYXBpS2V5EiQKDnBsYWluX3RleHRfa2V5GAIgASgJUgxwbGFpblRleHRLZXk=');

@$core.Deprecated('Use listApiKeysResponseDescriptor instead')
const ListApiKeysResponse$json = {
  '1': 'ListApiKeysResponse',
  '2': [
    {
      '1': 'api_keys',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.ApiKey',
      '10': 'apiKeys'
    },
  ],
};

/// Descriptor for `ListApiKeysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listApiKeysResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0QXBpS2V5c1Jlc3BvbnNlEikKCGFwaV9rZXlzGAEgAygLMg4ud2F5YW5nLkFwaUtleV'
    'IHYXBpS2V5cw==');

@$core.Deprecated('Use runAgentRequestDescriptor instead')
const RunAgentRequest$json = {
  '1': 'RunAgentRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'prompt', '3': 2, '4': 1, '5': 9, '10': 'prompt'},
    {'1': 'provider_id', '3': 3, '4': 1, '5': 9, '10': 'providerId'},
    {'1': 'model_id', '3': 4, '4': 1, '5': 9, '10': 'modelId'},
    {'1': 'workspace_path', '3': 5, '4': 1, '5': 9, '10': 'workspacePath'},
    {'1': 'agent_profile', '3': 6, '4': 1, '5': 9, '10': 'agentProfile'},
  ],
};

/// Descriptor for `RunAgentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runAgentRequestDescriptor = $convert.base64Decode(
    'Cg9SdW5BZ2VudFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEhYKBnByb2'
    '1wdBgCIAEoCVIGcHJvbXB0Eh8KC3Byb3ZpZGVyX2lkGAMgASgJUgpwcm92aWRlcklkEhkKCG1v'
    'ZGVsX2lkGAQgASgJUgdtb2RlbElkEiUKDndvcmtzcGFjZV9wYXRoGAUgASgJUg13b3Jrc3BhY2'
    'VQYXRoEiMKDWFnZW50X3Byb2ZpbGUYBiABKAlSDGFnZW50UHJvZmlsZQ==');

@$core.Deprecated('Use runAgentEventDescriptor instead')
const RunAgentEvent$json = {
  '1': 'RunAgentEvent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'payload', '3': 3, '4': 1, '5': 9, '10': 'payload'},
  ],
};

/// Descriptor for `RunAgentEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runAgentEventDescriptor = $convert.base64Decode(
    'Cg1SdW5BZ2VudEV2ZW50EhIKBHR5cGUYASABKAlSBHR5cGUSGAoHY29udGVudBgCIAEoCVIHY2'
    '9udGVudBIYCgdwYXlsb2FkGAMgASgJUgdwYXlsb2Fk');

@$core.Deprecated('Use providerInfoDescriptor instead')
const ProviderInfo$json = {
  '1': 'ProviderInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'capabilities', '3': 4, '4': 3, '5': 9, '10': 'capabilities'},
  ],
};

/// Descriptor for `ProviderInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List providerInfoDescriptor = $convert.base64Decode(
    'CgxQcm92aWRlckluZm8SDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZG'
    'VzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEiIKDGNhcGFiaWxpdGllcxgEIAMoCVIMY2Fw'
    'YWJpbGl0aWVz');

@$core.Deprecated('Use listProvidersResponseDescriptor instead')
const ListProvidersResponse$json = {
  '1': 'ListProvidersResponse',
  '2': [
    {
      '1': 'providers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.ProviderInfo',
      '10': 'providers'
    },
  ],
};

/// Descriptor for `ListProvidersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProvidersResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0UHJvdmlkZXJzUmVzcG9uc2USMgoJcHJvdmlkZXJzGAEgAygLMhQud2F5YW5nLlByb3'
    'ZpZGVySW5mb1IJcHJvdmlkZXJz');

@$core.Deprecated('Use modelInfoDescriptor instead')
const ModelInfo$json = {
  '1': 'ModelInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'format', '3': 4, '4': 1, '5': 9, '10': 'format'},
    {'1': 'size_bytes', '3': 5, '4': 1, '5': 3, '10': 'sizeBytes'},
  ],
};

/// Descriptor for `ModelInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List modelInfoDescriptor = $convert.base64Decode(
    'CglNb2RlbEluZm8SDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3'
    'JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEhYKBmZvcm1hdBgEIAEoCVIGZm9ybWF0Eh0KCnNp'
    'emVfYnl0ZXMYBSABKANSCXNpemVCeXRlcw==');

@$core.Deprecated('Use listModelsRequestDescriptor instead')
const ListModelsRequest$json = {
  '1': 'ListModelsRequest',
  '2': [
    {'1': 'provider_id', '3': 1, '4': 1, '5': 9, '10': 'providerId'},
  ],
};

/// Descriptor for `ListModelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listModelsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0TW9kZWxzUmVxdWVzdBIfCgtwcm92aWRlcl9pZBgBIAEoCVIKcHJvdmlkZXJJZA==');

@$core.Deprecated('Use listModelsResponseDescriptor instead')
const ListModelsResponse$json = {
  '1': 'ListModelsResponse',
  '2': [
    {
      '1': 'models',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wayang.ModelInfo',
      '10': 'models'
    },
  ],
};

/// Descriptor for `ListModelsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listModelsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0TW9kZWxzUmVzcG9uc2USKQoGbW9kZWxzGAEgAygLMhEud2F5YW5nLk1vZGVsSW5mb1'
    'IGbW9kZWxz');
