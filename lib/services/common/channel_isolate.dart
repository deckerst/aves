import 'dart:async';
import 'dart:isolate';

import 'package:aves/services/common/channel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// TODO TLAD remove experiment if useless
// Experiment: drop-in replacement for `MethodChannel` to perform calls in an `Isolate`
class ChannelIsolate {
  final Map<int, Completer<Object?>> _requestCompleters = {};
  int _nextRequestId = 0;
  late Future<SendPort> _isolateRequestPort;
  final String channelName;

  ChannelIsolate(this.channelName) {
    _isolateRequestPort = _initRequestPort();
  }

  // do not pass parameters from constructor
  Future<SendPort> _initRequestPort() async {
    // The helper isolate is going to send us back a SendPort, which we want to wait for.
    final Completer<SendPort> requestPortCompleter = Completer<SendPort>();

    final ReceivePort receivePort = ReceivePort()
      ..listen((message) {
        if (message is SendPort) {
          // The helper isolate sent us the port on which we can sent it requests.
          requestPortCompleter.complete(message);
        } else if (message is IsolateChannelResponse) {
          // The helper isolate sent us a response to a request we sent.
          final requestId = message.id;
          final Completer<Object?>? resultCompleter = _requestCompleters.remove(requestId);
          if (resultCompleter == null) {
            throw UnsupportedError('Missing completer for requestId=$requestId');
          }

          final error = message.error;
          if (error != null) {
            resultCompleter.completeError(error, message.stack);
          } else {
            resultCompleter.complete(message.result);
          }
        } else {
          throw UnsupportedError('Unsupported message type: ${message.runtimeType}');
        }
      });

    Future<void> entryPoint(_IsolateData isolateData) async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);

      final ReceivePort helperReceivePort = ReceivePort()
        ..listen((message) async {
          if (message is IsolateChannelRequest) {
            // do not use outer instance member `channelName`, only message members
            final channel = AvesChannels.byName(message.channelName);

            final id = message.id;
            IsolateChannelResponse response;
            try {
              final result = await channel.invokeMethod(message.method, message.arguments);
              response = IsolateChannelResponse.success(id, result);
            } on PlatformException catch (e, stack) {
              response = IsolateChannelResponse.exception(id, e, stack);
            }
            isolateData.answerPort.send(response);
          } else {
            throw UnsupportedError('Unsupported message type: ${message.runtimeType}');
          }
        });

      // Send the port to the main isolate on which we can receive requests.
      isolateData.answerPort.send(helperReceivePort.sendPort);
    }

    await Isolate.spawn<_IsolateData>(
      entryPoint,
      _IsolateData(
        token: ServicesBinding.rootIsolateToken!,
        answerPort: receivePort.sendPort,
      ),
      debugName: channelName,
    );

    // Wait until the helper isolate has sent us back the SendPort on which we can start sending requests.
    return requestPortCompleter.future;
  }

  // use an isolate so this platform call does not block the main isolate
  Future<Object?> invokeMethod(String method, [Map<String, Object?>? arguments]) async {
    final requestId = _nextRequestId++;
    final requestPort = await _isolateRequestPort;
    final Completer<Object?> completer = Completer<Object?>();
    _requestCompleters[requestId] = completer;
    requestPort.send(IsolateChannelRequest(requestId, channelName, method, arguments));
    return completer.future;
  }
}

@immutable
class IsolateChannelRequest extends Equatable {
  final int id;
  final String channelName;
  final String method;
  final Map<String, Object?>? arguments;

  @override
  List<Object?> get props => [id, method, arguments];

  const IsolateChannelRequest(this.id, this.channelName, this.method, this.arguments);
}

@immutable
class IsolateChannelResponse extends Equatable {
  final int id;
  final Object? result;
  final Exception? error;
  final StackTrace? stack;

  @override
  List<Object?> get props => [id, result, error, stack];

  const IsolateChannelResponse._private(this.id, this.result, this.error, this.stack);

  factory IsolateChannelResponse.success(int id, Object? result) {
    return IsolateChannelResponse._private(id, result, null, null);
  }

  factory IsolateChannelResponse.exception(int id, Exception? e, [StackTrace? stack]) {
    return IsolateChannelResponse._private(id, null, e, stack);
  }
}

class _IsolateData {
  final RootIsolateToken token;
  final SendPort answerPort;

  _IsolateData({
    required this.token,
    required this.answerPort,
  });
}
