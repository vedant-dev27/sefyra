import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sefyra/model/broadcast_model.dart';
import 'package:sefyra/services/udp_recieve.dart';
import 'package:sefyra/services/tcp_sender.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final ReceiveBroadcast _receiver = ReceiveBroadcast();

  final Map<String, BroadcastModel> _devices = {};
  final Map<String, DateTime> _lastSeenTime = {};

  Timer? _cleanupTimer;

  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;

  bool _isSending = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startListening();
    _startCleanupTimer();
  }

  // =====================
  // UDP LISTENING
  // =====================
  void _startListening() {
    _receiver.start(
      onPeerFound: (peer) {
        setState(() {
          _devices[peer.deviceName] = peer;
          _lastSeenTime[peer.deviceName] = DateTime.now();
        });
      },
    );
  }

  // =====================
  // CLEANUP
  // =====================
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isSending) return;

      final cutoff = DateTime.now().subtract(const Duration(seconds: 2));

      final stale = _lastSeenTime.entries
          .where((e) => e.value.isBefore(cutoff))
          .map((e) => e.key)
          .toList();

      if (stale.isNotEmpty) {
        setState(() {
          for (final name in stale) {
            _devices.remove(name);
            _lastSeenTime.remove(name);
          }
        });
      }
    });
  }

  // =====================
  // FILE PICKER
  // =====================
  Future<void> _pickFile() async {
    if (_isSending) return;

    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _selectedFileSize = result.files.single.size;
      });
    }
  }

  // =====================
  // SEND FILE
  // =====================
  Future<void> _sendFile(BroadcastModel peer) async {
    if (_selectedFile == null || _isSending) return;

    setState(() {
      _isSending = true;
      _progress = 0;
    });

    final sender = TcpSender();
    bool success = false;
    Object? error;

    try {
      await sender.send(
        ip: peer.ipAddress,
        file: _selectedFile!,
        fileName: _selectedFileName!,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
      );
      success = true;
    } catch (e) {
      error = e;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File sent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Send failed: $error")),
      );
    }

    setState(() {
      _isSending = false;
      _progress = 0;
    });
  }

  @override
  void dispose() {
    _receiver.stop();
    _cleanupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceNames = _devices.keys.toList();

    return Scaffold(
      body: Column(
        children: [
          // FILE SELECTOR
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Select File"),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFile != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(_selectedFileName!),
                        subtitle: Text(
                          "${(_selectedFileSize! / 1024).toStringAsFixed(2)} KB",
                        ),
                      ),
                    ),
                  if (_isSending) ...[
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: _progress),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // DEVICE LIST
          Expanded(
            flex: 1,
            child: deviceNames.isEmpty
                ? const Center(child: Text("Scanning for devices..."))
                : ListView.builder(
                    itemCount: deviceNames.length,
                    itemBuilder: (context, index) {
                      final name = deviceNames[index];
                      final peer = _devices[name]!;

                      return ListTile(
                        leading: const Icon(Icons.devices),
                        title: Text(name),
                        subtitle: Text(peer.ipAddress),
                        enabled: !_isSending,
                        onTap: () => _sendFile(peer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
