// skill_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// ============ Models ============
class SkillFile {
  final String name;
  final String path;
  final bool isDirectory;
  final List<SkillFile>? children;
  final String? extension;
  final int? size;
  final DateTime? modified;

  SkillFile({
    required this.name,
    required this.path,
    this.isDirectory = false,
    this.children,
    this.extension,
    this.size,
    this.modified,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'isDirectory': isDirectory,
    'children': children?.map((c) => c.toJson()).toList(),
    'extension': extension,
    'size': size,
    'modified': modified?.toIso8601String(),
  };

  factory SkillFile.fromJson(Map<String, dynamic> json) => SkillFile(
    name: json['name'],
    path: json['path'],
    isDirectory: json['isDirectory'],
    children: json['children'] != null
        ? List<SkillFile>.from(json['children'].map((c) => SkillFile.fromJson(c)))
        : null,
    extension: json['extension'],
    size: json['size'],
    modified: json['modified'] != null ? DateTime.parse(json['modified']) : null,
  );

  String get fileIcon {
    if (isDirectory) return '📁';
    if (extension == null) return '📄';
    
    switch (extension!.toLowerCase()) {
      case '.md':
        return '📝';
      case '.py':
        return '🐍';
      case '.js':
      case '.ts':
      case '.jsx':
      case '.tsx':
        return '📦';
      case '.json':
        return '📋';
      case '.txt':
        return '📄';
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.gif':
        return '🖼️';
      case '.pdf':
        return '📕';
      case '.zip':
      case '.tar':
      case '.gz':
        return '📦';
      default:
        return '📄';
    }
  }

  String get formattedSize {
    if (size == null) return '';
    if (size! >= 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (size! >= 1024) {
      return '${(size! / 1024).toStringAsFixed(1)} KB';
    }
    return '$size B';
  }
}

class SkillDetail {
  final String id;
  final String name;
  final String author;
  final String? description;
  final String? content;
  final String? license;
  final String? version;
  final DateTime? lastUpdated;
  final List<SkillFile> files;
  final Map<String, dynamic> metadata;

  SkillDetail({
    required this.id,
    required this.name,
    required this.author,
    this.description,
    this.content,
    this.license,
    this.version,
    this.lastUpdated,
    this.files = const [],
    this.metadata = const {},
  });

  factory SkillDetail.fromJson(Map<String, dynamic> json) => SkillDetail(
    id: json['id'],
    name: json['name'],
    author: json['author'],
    description: json['description'],
    content: json['content'],
    license: json['license'],
    version: json['version'],
    lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    files: json['files'] != null
        ? List<SkillFile>.from(json['files'].map((f) => SkillFile.fromJson(f)))
        : [],
    metadata: json['metadata'] ?? {},
  );
}

// ============ Providers ============
final skillDetailProvider = FutureProvider.family<SkillDetail?, String>((ref, id) async {
  // Simulate loading skill detail
  await Future.delayed(const Duration(milliseconds: 500));
  
  // In production, fetch from API or local storage
  return _getDefaultSkillDetail(id);
});

SkillDetail _getDefaultSkillDetail(String id) {
  return SkillDetail(
    id: id,
    name: 'mcp-builder',
    author: 'Anthropic',
    description: 'Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).',
    content: '''# MCP Server Development Guide

## Overview
Create MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. The quality of an MCP server is measured by how well it enables LLMs to accomplish real-world tasks.

## Key Concepts

### Tools
Tools are the primary interface between LLMs and external services. Each tool should:
- Have a clear, descriptive name
- Include comprehensive documentation
- Accept well-defined parameters
- Return structured results

### Best Practices
1. **Design for LLMs**: Write documentation that helps LLMs understand when and how to use each tool
2. **Error Handling**: Provide meaningful error messages that help LLMs recover
3. **Performance**: Optimize for latency and reliability
4. **Security**: Implement proper authentication and authorization

## Getting Started

### Prerequisites
- Python 3.8+ or Node.js 16+
- Basic understanding of APIs and services

### Installation
```bash
# Python
pip install mcp-sdk

# Node.js
npm install @modelcontextprotocol/sdk