import 'package:flutter/material.dart';

enum DebugType {
  statusCode,
  info,
  error,
  response,
  url,
}

void pprint(dynamic value, [DebugType? type, String? tag]) {
  switch (type) {
    case DebugType.statusCode:
      {
        debugPrint('\x1B[33m💎 STATUS CODE ${tag??''}: $value\x1B[0m');
        break;
      }
    case DebugType.info:
      {
        debugPrint('\x1B[32m⚡ INFO ${tag??''}: $value\x1B[0m');
        break;
      }
    case DebugType.error:
      {
        debugPrint('\x1B[31m🚨 ERROR ${tag??''}: $value\x1B[0m');
        break;
      }
    case DebugType.response:
      {
        debugPrint('\x1B[36m💡 RESPONSE ${tag??''}: $value\x1B[0m');
        break;
      }
    case DebugType.url:
      {
        debugPrint('\x1B[34m📌 URL ${tag??''}: $value\x1B[0m');
        break;
      }
    default:
      {
        debugPrint('\x1B[32m⚡ INFO ${tag??''}: $value\x1B[0m');
        break;
      }
  }
}
