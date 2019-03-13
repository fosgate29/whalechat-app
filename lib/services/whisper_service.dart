import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:hex/hex.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:whalechat_app/utils/utils.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whalechat_app/models/message.dart';
import 'package:whalechat_app/utils/app_config.dart';
import 'package:whalechat_app/utils/app_state.dart';

const WHISPER_NODE_LIST_URL =
  'https://raw.githubusercontent.com/status-im/status-react/80aa0e92864c638777a45c3f2aeb66c3ae7c0b2e/resources/config/fleets.json';
const SOCKET_TIMEOUT_SEC = 3;

class WhisperService {
  final _toastMessagesController = StreamController<String>();
  final nodeAddresses = <String>[];

  Stream<String> toastMessages;
  Set<String> _subscribedTopics = Set();

  Map<String, Stream<Message>> topicMessages = {};
  Map<String, StreamController<Message>> _topicMessageControllers = {};
  IOWebSocketChannel channel;

  var _connected = false;

  json_rpc.Client __client;
  IOWebSocketChannel _socket;

  json_rpc.Client get _client {
    if (__client == null || __client.isClosed) {
      _socket = IOWebSocketChannel.connect(
        (AppState.instance.storage.sandboxEnvironmentEnabled == true) ? sandbox_shhRpcServerUrl: shhRpcServerUrl
      );

      // Dupe the stream so that we can use it for JSON-RPC like calls and also pick up `shh_subscription`s
      final stream = _socket.stream.asBroadcastStream();

      stream.listen(onData);
      __client = json_rpc.Client(StreamChannel(
        DelegatingStream.typed(stream), DelegatingStreamSink.typed(_socket.sink)));
      __client.listen();
    }
    return __client;
  }

  WhisperService() {
    toastMessages = _toastMessagesController.stream.asBroadcastStream();
  }

  void onData(dynamic data) {
    final payload = json.decode(data);

    if (payload['jsonrpc'] != '2.0') return;

    switch (payload['method']) {
      case 'shh_subscription':
        final topic = payload['params']['result']['topic'];

        if (!_topicMessageControllers.containsKey(topic))
          break;

        final decoder = HexDecoder().fuse(AsciiDecoder());
        final payloadJson = decoder.convert(payload['params']['result']['payload'].toString().substring(2));
        final m = Message.fromJson(json.decode(payloadJson));

        _topicMessageControllers[topic].add(m);

        break;
    }
  }

  _toast(String m) => _toastMessagesController.add(m);

  _ensureConnected() {
    if (!_connected)
      throw Exception("AppState used before initialization");
  }

  void connect() async {
    if (_connected)
      return;

    if (AppState.instance.shhSymKeyId == null) {
      AppState.instance.shhSymKeyId = await _client.sendRequest("shh_addSymKey", [shhSymKey]);
    }

    _connected = true;
    _toast("Connected!");
  }

  Future<void> subscribeToRoom(String topic) async {
    _ensureConnected();

    _toastMessagesController.add("Loading messages...");

    if (!_subscribedTopics.contains(topic)) {
      await _client.sendRequest("shh_subscribe", ["messages", {
        "symKeyID": AppState.instance.shhSymKeyId,
        "topics": [topic],
        "ttl": 200,
        "minPow": 0.8,
      }]);
      _subscribedTopics.add(topic);
    }

    _toastMessagesController.add("Connected");

    _topicMessageControllers[topic] = StreamController<Message>();
    topicMessages[topic] = _topicMessageControllers[topic].stream;
  }

  void unsubscribeFromRoom(String topic) {
    _topicMessageControllers.remove(topic);
    topicMessages.remove(topic);
  }


  void sendMessage(String topic, Message message) async {
    _ensureConnected();

    final payload = AsciiEncoder().fuse(HexEncoder()).convert(
      json.encode(message.toJson()));

    await _client.sendRequest("shh_post", [{
      "symKeyID": AppState.instance.shhSymKeyId,
      "topic": "$topic",
      "payload": "0x$payload",
      "powTime": 5,
      "powTarget": 1,
    }]);
  }

  void disconnect() {}

  Future<bool> _isNodeUp(String ip, int port) async {
    final address = "$ip:$port";
    dbgPrint('Trying to connect to ' + address);
    try {
      await Socket.connect(
        ip, port, timeout: Duration(seconds: SOCKET_TIMEOUT_SEC));
      dbgPrint('Could connect to ' + address);
      return true;
    } catch (_) {
      dbgPrint('Could not connect to ' + address);
    }
    return false;
  }

  Future checkWhisperNodes() async {
    nodeAddresses.clear();

    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(WHISPER_NODE_LIST_URL));
    final response = await request.close();

    Future readResponse(HttpClientResponse response) async {
      final completer = Completer();
      final contents = StringBuffer();
      response.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    }
    final processedResponse = await readResponse(response);
    Map jsonResponse = json.decode(processedResponse.toString());
    Map someNodesMap = jsonResponse['fleets']['eth.beta']['whisper'];

    for (var key in someNodesMap.keys) {
      final value = someNodesMap[key];
      final address = value.split('@')[1];
      final ip = address.split(':')[0];
      final port = int.parse(address.split(':')[1]);
      if (await _isNodeUp(ip, port)) {
        nodeAddresses.add(address);
      }
    }
  }
}

