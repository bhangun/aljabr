import 'package:grpc/grpc.dart';
import '../src/generated/wayang.pbgrpc.dart';

class GrpcClient {
  static final GrpcClient _instance = GrpcClient._internal();
  factory GrpcClient() => _instance;

  late ClientChannel channel;
  late ProjectServiceClient projectClient;
  late ApiKeyServiceClient apiClient;

  GrpcClient._internal() {
    // Port 9000 is the default Quarkus gRPC port
    channel = ClientChannel(
      'localhost',
      port: 9000,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(), // Local dev
      ),
    );

    // This interceptor automatically attaches the hardcoded default tenant ID
    final tenantInterceptor = ClientInterceptor(
      (ClientMethod method, Stream requests, CallOptions options, invoker) {
        final newOptions = options.mergedWith(
          CallOptions(metadata: {'X-Tenant-Id': 'default-tenant'}),
        );
        return invoker(method, requests, newOptions);
      },
    );

    projectClient = ProjectServiceClient(channel, interceptors: [tenantInterceptor]);
    apiClient = ApiKeyServiceClient(channel, interceptors: [tenantInterceptor]);
  }
}

// Global instance
final grpcClient = GrpcClient();
