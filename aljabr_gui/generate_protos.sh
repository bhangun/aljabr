#!/bin/bash

# Ensure the directories exist
mkdir -p protos
mkdir -p lib/src/generated

# Install the dart protobuf compiler plugin globally if not installed
dart pub global activate protoc_plugin

# Add pub-cache bin to PATH if not already
export PATH="$PATH:$HOME/.pub-cache/bin"

# Compile the protos
protoc --dart_out=grpc:lib/src/generated -Iprotos protos/wayang.proto

echo "Protobuf files generated successfully in lib/src/generated"
