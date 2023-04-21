/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// 自定义日志的级别
enum LogLevel { debug, info, warning, error }

/// 崩溃收集服务入口类
class AGCCrash {
  static const MethodChannel _channel = const MethodChannel('com.huawei.flutter/agconnect_crash');

  /// 获取AGCCrash实例
  static final AGCCrash instance = AGCCrash();

  Future<void> onFlutterError(FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    recordError(details.exceptionAsString(), details.stack);
  }

  Future<void> recordError(dynamic exception, StackTrace stack, { bool fatal = false}) async {
    assert(exception != null);
    stack ??= StackTrace.current ?? StackTrace.fromString('');
    print('Error caught by AGCCrash : ${exception.toString()} \n${stack.toString()}');
    await _channel.invokeMethod('recordError', <String, String>{
      'reason': exception.toString(),
      'stack':stack.toString(),
      'fatal':fatal.toString(),
    });
    return;
  }

  /// 制造一个崩溃，用于开发者调试
  Future<void> testIt() {
    return _channel.invokeMethod('testIt');
  }

  /// 设置是否收集和上报应用的崩溃信息，默认为true
  /// enable为true表示收集并上报崩溃信息，false表示不收集且不上报崩溃信息。
  Future<void> enableCrashCollection(bool enable) {
    return _channel.invokeMethod('enableCrashCollection', <String, bool>{
      'enable': enable,
    });
  }

  /// 设置自定义用户标识符
  Future<void> setUserId(String userId) {
    assert(userId != null);
    return _channel.invokeMethod('setUserId', <String, String>{
      'userId': userId,
    });
  }

  /// 添加自定义键值对
  Future<void> setCustomKey(String key, dynamic value) {
    assert(key != null);
    return _channel.invokeMethod('setCustomKey', <String, String>{
      'key': key,
      'value': value.toString()
    });
  }

  /// 添加自定义日志
  Future<void> log(
      {LogLevel level = LogLevel.info, @required String message}) {
    assert(message != null);
    return _channel.invokeMethod(
        'customLog', <String, dynamic>{'level': level.index, 'message': message});
  }
}
