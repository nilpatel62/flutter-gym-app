import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import '../services/supabase_service.dart';

enum ExerciseType { squat, pushup, deadlift }

class ExerciseSelectScreen extends StatelessWidget {
  const ExerciseSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Exercise'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              // Navigation will be handled by auth state listener
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Select Your Exercise',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an exercise to start your form coaching session',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _ExerciseCard(
                  title: 'Squat',
                  subtitle: 'Side View',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  exercise: ExerciseType.squat,
                ),
                const SizedBox(height: 16),
                _ExerciseCard(
                  title: 'Push-up',
                  subtitle: 'Side View',
                  icon: Icons.sports_gymnastics,
                  color: Colors.orange,
                  exercise: ExerciseType.pushup,
                ),
                const SizedBox(height: 16),
                _ExerciseCard(
                  title: 'Deadlift',
                  subtitle: 'Side View',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  exercise: ExerciseType.deadlift,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Setup Tips',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TipItem(icon: Icons.height, text: 'Place phone at waist height'),
                      const SizedBox(height: 8),
                      _TipItem(icon: Icons.straighten, text: 'Position 2–3 meters away'),
                      const SizedBox(height: 8),
                      _TipItem(icon: Icons.person_outline, text: 'Ensure full body is visible'),
                      const SizedBox(height: 8),
                      _TipItem(icon: Icons.camera_alt_outlined, text: 'Side view only'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ExerciseType exercise;

  const _ExerciseCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SetupScreen(exercise: exercise)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class SetupScreen extends StatefulWidget {
  final ExerciseType exercise;
  const SetupScreen({super.key, required this.exercise});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _isLoading = false;

  String get title => switch (widget.exercise) {
    ExerciseType.squat => "Squat Setup",
    ExerciseType.pushup => "Push-up Setup",
    ExerciseType.deadlift => "Deadlift Setup",
  };

  String get exerciseName => switch (widget.exercise) {
    ExerciseType.squat => "Squat",
    ExerciseType.pushup => "Push-up",
    ExerciseType.deadlift => "Deadlift",
  };

  IconData get exerciseIcon => switch (widget.exercise) {
    ExerciseType.squat => Icons.fitness_center,
    ExerciseType.pushup => Icons.sports_gymnastics,
    ExerciseType.deadlift => Icons.trending_up,
  };

  Color get exerciseColor => switch (widget.exercise) {
    ExerciseType.squat => Colors.blue,
    ExerciseType.pushup => Colors.orange,
    ExerciseType.deadlift => Colors.purple,
  };

  Future<void> _checkPermissionAndStart() async {
    setState(() => _isLoading = true);

    try {
      // Check current permission status
      final status = await Permission.camera.status;
      
      // Handle permanently denied first (user must go to Settings)
      if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showPermissionPermanentlyDeniedDialog();
          return;
        }
      }
      
      // If denied, request permission
      if (status.isDenied) {
        final result = await Permission.camera.request();
        
        if (result.isPermanentlyDenied) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showPermissionPermanentlyDeniedDialog();
            return;
          }
        }
        
        if (result.isDenied) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showPermissionDeniedDialog();
            return;
          }
        }
      }

      // Check again after request to ensure we have permission
      final finalStatus = await Permission.camera.status;
      if (!finalStatus.isGranted) {
        if (mounted) {
          setState(() => _isLoading = false);
          if (finalStatus.isPermanentlyDenied) {
            _showPermissionPermanentlyDeniedDialog();
          } else {
            _showPermissionDeniedDialog();
          }
          return;
        }
      }

      // Permission granted, proceed with camera setup
      if (mounted) {
        final cameras = await availableCameras();
        final cam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveCoachScreen(exercise: widget.exercise, camera: cam),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.orange),
            SizedBox(width: 12),
            Text('Camera Permission Required'),
          ],
        ),
        content: const Text(
          'Camera access is required to use the form coach feature. '
          'Please grant camera permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPermissionAndStart();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.red),
            SizedBox(width: 12),
            Text('Camera Permission Required'),
          ],
        ),
        content: const Text(
          'Camera permission has been denied. To enable it:\n\n'
          '1. Tap "Open Settings" below\n'
          '2. Find "Form Coach" in the list\n'
          '3. Toggle "Camera" to ON\n'
          '4. Return to the app and try again\n\n'
          'If "Form Coach" doesn\'t appear in Settings, please uninstall and reinstall the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              exerciseColor.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exerciseIcon,
                    size: 64,
                    color: exerciseColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Setup Instructions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _SetupInstructionCard(
                  icon: Icons.camera_alt,
                  title: 'Camera Position',
                  description: 'Place your phone at waist height, 2–3 meters away',
                  color: exerciseColor,
                ),
                const SizedBox(height: 16),
                _SetupInstructionCard(
                  icon: Icons.person_outline,
                  title: 'Body Position',
                  description: 'Ensure your full body is visible in the frame',
                  color: exerciseColor,
                ),
                const SizedBox(height: 16),
                _SetupInstructionCard(
                  icon: Icons.light_mode,
                  title: 'Lighting',
                  description: 'Make sure you have good lighting for better detection',
                  color: exerciseColor,
                ),
                const SizedBox(height: 16),
                _SetupInstructionCard(
                  icon: Icons.swap_horiz,
                  title: 'Side View Only',
                  description: 'Position yourself so the camera captures your side profile',
                  color: exerciseColor,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _checkPermissionAndStart,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isLoading ? 'Starting...' : 'Start Live Coach'),
                    style: FilledButton.styleFrom(
                      backgroundColor: exerciseColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupInstructionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _SetupInstructionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveCoachScreen extends StatefulWidget {
  final ExerciseType exercise;
  final CameraDescription camera;
  const LiveCoachScreen({super.key, required this.exercise, required this.camera});

  @override
  State<LiveCoachScreen> createState() => _LiveCoachScreenState();
}

class _LiveCoachScreenState extends State<LiveCoachScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  late final PoseDetector _poseDetector;
  late final AudioPlayer _player;

  late final FormEngine _engine;

  String _status = "Initializing…";
  int _reps = 0;
  int _score = 0;
  String _tip = "Stand in frame (side view)";
  int _lastAlertMs = 0;

  // basic throttle: process every Nth frame
  int _frameIndex = 0;
  static const int _processEveryNFrames = 2;

  @override
  void initState() {
    super.initState();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );

    _player = AudioPlayer();
    _engine = FormEngine(exercise: widget.exercise);
    _init();
  }

  Future<void> _init() async {
    // Check permission status first
    final camPermStatus = await Permission.camera.status;
    
    if (camPermStatus.isDenied) {
      final camPerm = await Permission.camera.request();
      if (!camPerm.isGranted) {
        if (mounted) {
          setState(() => _status = "Camera permission denied");
          _showPermissionError();
        }
        return;
      }
    } else if (camPermStatus.isPermanentlyDenied) {
      if (mounted) {
        setState(() => _status = "Camera permission permanently denied");
        _showPermissionError();
      }
      return;
    }

    try {
      final ctrl = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await ctrl.initialize();
      await ctrl.startImageStream(_onCameraImage);

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _status = "Live";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = "Error initializing camera: $e");
      }
    }
  }

  void _showPermissionError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.orange),
                SizedBox(width: 12),
                Text('Camera Permission Required'),
              ],
            ),
            content: const Text(
              'Camera access is required to use the form coach. '
              'Please grant camera permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (!mounted) return;
    if (_isProcessing) return;
    _frameIndex++;
    if (_frameIndex % _processEveryNFrames != 0) return;

    _isProcessing = true;
    try {
      final inputImage = _cameraImageToInputImage(image, _controller!);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        setState(() {
          _tip = "No body detected. Step back / improve lighting.";
          _score = 0;
        });
        return;
      }

      final pose = poses.first;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final result = _engine.update(pose, nowMs);

      setState(() {
        _reps = result.reps;
        _score = result.score;
        _tip = result.tip;
      });

      if (result.alertSeverity >= 3 && (nowMs - _lastAlertMs) > 1200) {
        _lastAlertMs = nowMs;
        await _beepAndVibrate();
      }
    } catch (e) {
      // keep silent; show minimal status
      setState(() => _status = "Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _beepAndVibrate() async {
    try {
      await _player.play(AssetSource('beep.mp3'), volume: 1.0);
    } catch (_) {}
    try {
      final canVibrate = await Vibration.hasVibrator() ?? false;
      if (canVibrate) {
        Vibration.vibrate(duration: 70);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Coach: ${widget.exercise.name.toUpperCase()}"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (ctrl == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (_status.contains("permission"))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Please grant camera permission to continue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(ctrl),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 16,
                    child: _HUD(reps: _reps, score: _score, tip: _tip, status: _status),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// -----------------------
/// HUD
/// -----------------------
class _HUD extends StatelessWidget {
  final int reps;
  final int score;
  final String tip;
  final String status;

  const _HUD({required this.reps, required this.score, required this.tip, required this.status});

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.repeat,
                      label: 'Reps',
                      value: reps.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      label: 'Score',
                      value: score.toString(),
                      color: _getScoreColor(score),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (status.isNotEmpty && status != "Live")
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// -----------------------
/// Pose -> Form Engine
/// -----------------------
class FormEngine {
  final ExerciseType exercise;
  final RepStateMachine _repSM = RepStateMachine();

  // Baselines
  double? _topHipY;
  double? _topShoulderY;

  // Score state
  int _currentRepIndex = 0;
  int _reps = 0;
  int _score = 100;

  // Alert severity for this frame (0-3)
  int _alertSeverity = 0;
  String _tip = "Hold still to calibrate…";

  // EMA smoothing
  final _ema = _EMA(alpha: 0.25);

  FormEngine({required this.exercise});

  FormResult update(Pose pose, int nowMs) {
    _alertSeverity = 0;
    _score = 100;

    final lm = pose.landmarks;

    // Required landmarks (we use LEFT by default; if missing, fallback to RIGHT)
    PoseLandmark? sh = lm[PoseLandmarkType.leftShoulder] ?? lm[PoseLandmarkType.rightShoulder];
    PoseLandmark? hp = lm[PoseLandmarkType.leftHip] ?? lm[PoseLandmarkType.rightHip];
    PoseLandmark? kn = lm[PoseLandmarkType.leftKnee] ?? lm[PoseLandmarkType.rightKnee];
    PoseLandmark? an = lm[PoseLandmarkType.leftAnkle] ?? lm[PoseLandmarkType.rightAnkle];
    PoseLandmark? heel = lm[PoseLandmarkType.leftHeel] ?? lm[PoseLandmarkType.rightHeel];
    PoseLandmark? toe = lm[PoseLandmarkType.leftFootIndex] ?? lm[PoseLandmarkType.rightFootIndex];

    if (sh == null || hp == null || kn == null || an == null || heel == null || toe == null) {
      return FormResult(reps: _reps, score: 0, tip: "Move into frame (full body).", alertSeverity: 0);
    }

    // Confidence gate (ML Kit has landmark "likelihood" via inFrameLikelihood)
    // Some versions provide it; if null, assume ok.
    final minLik = _minLikely([sh, hp, kn, an, heel, toe]);
    if (minLik != null && minLik < 0.55) {
      return FormResult(reps: _reps, score: 0, tip: "Low detection. Improve lighting / step back.", alertSeverity: 0);
    }

    // Scale normalization for thresholds
    final scale = (_dist(sh, hp) + _dist(hp, kn)).clamp(1.0, 1e9);

    // Smooth primary signals
    final hipY = _ema.f('hipY', hp.y);
    final shoulderY = _ema.f('shoulderY', sh.y);
    final heelY = _ema.f('heelY', heel.y);

    // Calibration for TOP references (first ~1.5s)
    _topHipY ??= hipY;
    _topShoulderY ??= shoulderY;

    // Slowly adapt top refs only when in TOP state (helps drift)
    if (_repSM.state == RepState.top) {
      _topHipY = _lerp(_topHipY!, hipY, 0.03);
      _topShoulderY = _lerp(_topShoulderY!, shoulderY, 0.03);
    }

    // Select rep signal per exercise
    double signal;
    switch (exercise) {
      case ExerciseType.squat:
      case ExerciseType.deadlift:
        signal = hipY;
        break;
      case ExerciseType.pushup:
        signal = shoulderY;
        break;
    }

    // Update rep state machine
    final repEvent = _repSM.update(
      nowMs: nowMs,
      signal: signal,
      topRef: (exercise == ExerciseType.pushup ? _topShoulderY! : _topHipY!),
      scale: scale,
    );

    // Compute angles
    final kneeAngle = _angleDeg(hp, kn, an);
    final hipAngle = _angleDeg(sh, hp, kn);
    final torsoLean = _torsoLeanDeg(sh, hp);

    // Per-exercise checks
    switch (exercise) {
      case ExerciseType.squat:
        _squatChecks(
          kneeAngleDeg: kneeAngle,
          torsoLeanDeg: torsoLean,
          heelY: heelY,
          heelTopY: (_ema.get('heelTopY') ?? heelY),
          toeX: toe.x,
          kneeX: kn.x,
          scale: scale,
          phase: _repSM.state,
        );
        break;

      case ExerciseType.pushup:
        _pushupChecks(
          hipAngleDeg: hipAngle,
          shoulderY: shoulderY,
          topShoulderY: _topShoulderY!,
          scale: scale,
          phase: _repSM.state,
          repMs: _repSM.currentRepMs(nowMs),
        );
        break;

      case ExerciseType.deadlift:
        _deadliftChecks(
          torsoLeanDeg: torsoLean,
          hipY: hipY,
          shoulderY: shoulderY,
          scale: scale,
          phase: _repSM.state,
        );
        break;
    }

    // Save heel baseline while TOP (for squat checks)
    if (_repSM.state == RepState.top) {
      _ema.set('heelTopY', heelY);
    }

    // Rep finalized?
    if (repEvent == RepEvent.repCompleted) {
      _reps += 1;
      _currentRepIndex += 1;
    }

    // Friendly default tip
    _tip = _tip.isEmpty ? "Good form" : _tip;

    return FormResult(reps: _reps, score: _score.clamp(0, 100), tip: _tip, alertSeverity: _alertSeverity);
  }

  void _squatChecks({
    required double kneeAngleDeg,
    required double torsoLeanDeg,
    required double heelY,
    required double heelTopY,
    required double toeX,
    required double kneeX,
    required double scale,
    required RepState phase,
  }) {
    _tip = "Squat: keep steady";
    // Only judge in descent/bottom/early ascent
    if (phase == RepState.top) return;

    // 1) Depth (knee angle)
    if (kneeAngleDeg > 140) {
      _score -= 25;
      _alertSeverity = 3;
      _tip = "Go deeper (shallow squat).";
    } else if (kneeAngleDeg > 125) {
      _score -= 12;
      _tip = "Slightly deeper for full rep.";
    }

    // 2) Torso lean
    if (torsoLeanDeg > 50) {
      _score -= 25;
      _alertSeverity = math.max(_alertSeverity, 3);
      _tip = "Chest up. Don't fold forward.";
    } else if (torsoLeanDeg > 40) {
      _score -= 12;
      _tip = "Chest up a bit more.";
    }

    // 3) Heel lift (use delta from top)
    final heelRiseNorm = ((heelY - heelTopY).abs() / scale);
    if (heelRiseNorm > 0.035) {
      _score -= 25;
      _alertSeverity = math.max(_alertSeverity, 3);
      _tip = "Keep heels planted.";
    }

    // 4) Knee too forward (proxy) - only if also unstable/heel lift a bit
    final kneeForwardNorm = ((kneeX - toeX).abs() / scale);
    if (kneeForwardNorm > 0.10 && heelRiseNorm > 0.02) {
      _score -= 12;
      _tip = "Shift weight to mid-foot/heel.";
    }
  }

  void _pushupChecks({
    required double hipAngleDeg,
    required double shoulderY,
    required double topShoulderY,
    required double scale,
    required RepState phase,
    required int repMs,
  }) {
    _tip = "Push-up: keep body straight";
    if (phase == RepState.top) return;

    // Body line: hipAngle near 180 is straight
    if (hipAngleDeg < 155) {
      _score -= 25;
      _alertSeverity = 3;
      _tip = "Keep body straight (don't sag).";
    } else if (hipAngleDeg < 160) {
      _score -= 12;
      _tip = "Brace core, keep straight line.";
    }

    // Shallow ROM: shoulder drop from top
    final dropNorm = ((shoulderY - topShoulderY).abs() / scale);
    if (dropNorm < 0.08 && phase == RepState.bottom) {
      _score -= 25;
      _alertSeverity = math.max(_alertSeverity, 3);
      _tip = "Go lower for full rep.";
    } else if (dropNorm < 0.12 && phase == RepState.bottom) {
      _score -= 12;
      _tip = "Slightly lower for full rep.";
    }

    // Too fast: rep duration (rough)
    if (repMs > 0 && repMs < 500 && phase == RepState.bottom) {
      _score -= 12;
      _tip = "Control the descent.";
    }
  }

  void _deadliftChecks({
    required double torsoLeanDeg,
    required double hipY,
    required double shoulderY,
    required double scale,
    required RepState phase,
  }) {
    _tip = "Deadlift: brace and lift smooth";

    // We detect "hips shoot up" by comparing hip vs shoulder movement early in ascent.
    // We'll use EMA velocity proxies stored in the smoother.
    final hipPrev = _ema.get('hipPrev') ?? hipY;
    final shPrev = _ema.get('shPrev') ?? shoulderY;
    _ema.set('hipPrev', hipY);
    _ema.set('shPrev', shoulderY);

    final dHip = (hipPrev - hipY).abs();      // movement magnitude
    final dSh = (shPrev - shoulderY).abs();   // movement magnitude
    final ratio = dHip / (dSh + 1e-6);

    // Only judge during ascent (lift phase)
    if (phase == RepState.ascent) {
      if (ratio > 1.6) {
        _score -= 25;
        _alertSeverity = 3;
        _tip = "Don't let hips shoot up first.";
      }

      // Torso collapse proxy
      final setupLean = (_ema.get('dlSetupLean') ?? torsoLeanDeg);
      if (_ema.get('dlSetupLean') == null && phase == RepState.descent) {
        _ema.set('dlSetupLean', torsoLeanDeg);
      }
      final delta = torsoLeanDeg - setupLean;
      if (delta > 16) {
        _score -= 25;
        _alertSeverity = math.max(_alertSeverity, 3);
        _tip = "Brace core. Keep back neutral.";
      } else if (delta > 10) {
        _score -= 12;
        _tip = "Keep torso angle steady.";
      }
    }

    if (phase == RepState.top) {
      _ema.set('dlSetupLean', null);
    }
  }

  double? _minLikely(List<PoseLandmark> lms) {
    if (lms.isEmpty) return null;
    final vals = lms.map((l) => l.likelihood).toList();
    vals.sort();
    return vals.first;
  }

  double _dist(PoseLandmark a, PoseLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _angleDeg(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final bax = a.x - b.x;
    final bay = a.y - b.y;
    final bcx = c.x - b.x;
    final bcy = c.y - b.y;

    final dot = bax * bcx + bay * bcy;
    final mag1 = math.sqrt(bax * bax + bay * bay);
    final mag2 = math.sqrt(bcx * bcx + bcy * bcy);
    if (mag1 < 1e-6 || mag2 < 1e-6) return 180;

    final cos = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180.0 / math.pi;
    }

  double _torsoLeanDeg(PoseLandmark shoulder, PoseLandmark hip) {
    // angle between torso vector (shoulder->hip) and vertical axis
    final tx = shoulder.x - hip.x;
    final ty = shoulder.y - hip.y;

    // vertical vector (0, -1) in image coordinates (y down)
    final vx = 0.0;
    final vy = -1.0;

    final dot = tx * vx + ty * vy;
    final magT = math.sqrt(tx * tx + ty * ty);
    if (magT < 1e-6) return 0;

    final cos = (dot / (magT * 1.0)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180.0 / math.pi;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class FormResult {
  final int reps;
  final int score;
  final String tip;
  final int alertSeverity;
  FormResult({required this.reps, required this.score, required this.tip, required this.alertSeverity});
}

/// -----------------------
/// Rep State Machine
/// -----------------------
enum RepState { top, descent, bottom, ascent }
enum RepEvent { none, repCompleted }

class RepStateMachine {
  RepState state = RepState.top;

  double? _topRef;
  double _signalEma = 0;
  double _prevSignalEma = 0;

  int _repStartMs = 0;
  int _lastMs = 0;

  int _downFrames = 0;
  int _upFrames = 0;
  int _bottomHoldFrames = 0;
  int _topHoldFrames = 0;

  // tuning
  static const int minRepTimeMs = 800;

  RepEvent update({
    required int nowMs,
    required double signal,
    required double topRef,
    required double scale,
  }) {
    _lastMs = nowMs;
    _topRef = topRef;

    // simple EMA for signal
    _prevSignalEma = _signalEma;
    _signalEma = (_signalEma == 0) ? signal : (_signalEma * 0.75 + signal * 0.25);

    // y-down camera: moving "down" means signal increases
    final v = _signalEma - _prevSignalEma;
    final eps = 0.003 * scale;

    final movingDown = v > eps;
    final movingUp = v < -eps;

    final closeToTop = (signal - topRef).abs() < (0.04 * scale);

    switch (state) {
      case RepState.top:
        if (movingDown) {
          _downFrames++;
          if (_downFrames >= 3) {
            state = RepState.descent;
            _repStartMs = nowMs;
            _bottomHoldFrames = 0;
            _upFrames = 0;
          }
        } else {
          _downFrames = 0;
        }
        break;

      case RepState.descent:
        if (movingUp) {
          _upFrames++;
          if (_upFrames >= 2) {
            state = RepState.bottom;
            _bottomHoldFrames = 0;
          }
        } else {
          _upFrames = 0;
        }
        break;

      case RepState.bottom:
        if (movingUp) {
          _upFrames++;
        } else {
          _upFrames = 0;
        }
        _bottomHoldFrames++;
        if (_upFrames >= 2 || _bottomHoldFrames >= 3) {
          state = RepState.ascent;
          _topHoldFrames = 0;
        }
        break;

      case RepState.ascent:
        if (closeToTop) {
          _topHoldFrames++;
          if (_topHoldFrames >= 4) {
            state = RepState.top;
            _downFrames = 0;
            _upFrames = 0;

            final dur = nowMs - _repStartMs;
            if (dur >= minRepTimeMs) {
              return RepEvent.repCompleted;
            }
          }
        } else {
          _topHoldFrames = 0;
        }
        break;
    }

    return RepEvent.none;
  }

  int currentRepMs(int nowMs) => (state == RepState.top) ? 0 : (nowMs - _repStartMs);
}

/// -----------------------
/// EMA helper
/// -----------------------
class _EMA {
  final double alpha;
  final Map<String, double?> _m = {};
  _EMA({required this.alpha});

  double f(String k, double x) {
    final prev = _m[k];
    final v = (prev == null) ? x : (prev * (1 - alpha) + x * alpha);
    _m[k] = v;
    return v;
  }

  double? get(String k) => _m[k];
  void set(String k, double? v) => _m[k] = v;
}

/// -----------------------
/// CameraImage -> InputImage
/// -----------------------
InputImage _cameraImageToInputImage(CameraImage image, CameraController controller) {
  final bytes = _concatenatePlanes(image.planes);

  final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final imageRotation = InputImageRotationValue.fromRawValue(
        controller.description.sensorOrientation,
      ) ??
      InputImageRotation.rotation0deg;

  final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ??
      InputImageFormat.nv21;

  // For multiple planes, use the first plane's bytesPerRow
  // For single plane formats, use the plane's bytesPerRow directly
  final bytesPerRow = image.planes.isNotEmpty ? image.planes.first.bytesPerRow : image.width;

  final metadata = InputImageMetadata(
    size: imageSize,
    rotation: imageRotation,
    format: inputImageFormat,
    bytesPerRow: bytesPerRow,
  );

  return InputImage.fromBytes(bytes: bytes, metadata: metadata);
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final List<int> allBytes = [];
  for (final Plane plane in planes) {
    allBytes.addAll(plane.bytes);
  }
  return Uint8List.fromList(allBytes);
}

