import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// خدمة تسجيل ومعالجة الصوت
class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _currentRecordingPath;

  /// تهيئة خدمة الصوت
  Future<void> initialize() async {
    if (_isInitialized) return;

    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    await _player!.openPlayer();

    _isInitialized = true;
  }

  /// التحقق من أذونات الميكروفون وطلبها إذا لزم الأمر
  Future<bool> checkAndRequestPermissions() async {
    var status = await Permission.microphone.status;
    
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    
    return status.isGranted;
  }

  /// بدء التسجيل
  Future<String?> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('لم يتم منح إذن الميكروفون');
    }

    try {
      // إنشاء مسار مؤقت للملف
      final directory = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/quran_recording_$timestamp.aac';

      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      print('خطأ في بدء التسجيل: $e');
      rethrow;
    }
  }

  /// إيقاف التسجيل وإرجاع مسار الملف
  Future<String?> stopRecording() async {
    if (!_isRecording || _recorder == null) return null;

    try {
      await _recorder!.stopRecorder();
      _isRecording = false;
      
      return _currentRecordingPath;
    } catch (e) {
      print('خطأ في إيقاف التسجيل: $e');
      return null;
    }
  }

  /// تشغيل التسجيل
  Future<void> playRecording(String audioPath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _player!.startPlayer(
        fromURI: audioPath,
        codec: Codec.aacADTS,
      );
    } catch (e) {
      print('خطأ في تشغيل التسجيل: $e');
      rethrow;
    }
  }

  /// إيقاف تشغيل الصوت
  Future<void> stopPlaying() async {
    if (_player == null) return;
    
    try {
      await _player!.stopPlayer();
    } catch (e) {
      print('خطأ في إيقاف التشغيل: $e');
    }
  }

  /// الحصول على حالة التسجيل
  bool get isRecording => _isRecording;

  /// الحصول على مسار التسجيل الحالي
  String? get currentRecordingPath => _currentRecordingPath;

  /// حذف ملف التسجيل
  Future<void> deleteRecording(String audioPath) async {
    try {
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('خطأ في حذف الملف: $e');
    }
  }

  /// الحصول على مدة التسجيل الحالية (Stream)
  Stream<Duration>? getRecordingDuration() {
    return _recorder?.onProgress?.map((event) => event.duration);
  }

  /// إغلاق الخدمة وتحرير الموارد
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }

    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }

    if (_player != null) {
      await _player!.closePlayer();
      _player = null;
    }
    
    _isInitialized = false;
  }

  /// تسجيل وإرسال الصوت في خطوة واحدة (للراحة)
  Future<String> recordAndSend() async {
    // بدء التسجيل
    final path = await startRecording();
    
    // في تطبيق حقيقي، ستنتظر المستخدم أن ينهي القراءة
    // هنا نعيد المسار مباشرة للاستخدام مع api_service
    
    return path ?? 'mock_audio_file_path.aac';
  }
}