import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final splashFlowProvider =
    StateNotifierProvider<SplashFlowController, SplashFlowState>((ref) {
      return SplashFlowController(ref)..start();
    });

class SplashFlowController extends StateNotifier<SplashFlowState> {
  SplashFlowController(this._ref) : super(const SplashFlowState.initial());

  final Ref _ref;
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    final startedAt = DateTime.now();

    try {
      state = state.copyWith(
        currentStep: SplashStep.bootstrap,
        statusMessage: AppStrings.splashBootstrapMessage,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      _ref.read(appBootstrapProvider);
      state = state.copyWith(bootstrapReady: true);

      state = state.copyWith(
        currentStep: SplashStep.config,
        statusMessage: AppStrings.splashConfigMessage,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      _ref.read(appConfigProvider);
      state = state.copyWith(configReady: true);

      state = state.copyWith(
        currentStep: SplashStep.auth,
        statusMessage: AppStrings.splashSessionMessage,
      );
      await _ref.read(authControllerProvider.notifier).initialize();
      state = state.copyWith(authChecked: true);

      final elapsed = DateTime.now().difference(startedAt);
      const minimumDuration = Duration(milliseconds: 2200);
      if (elapsed < minimumDuration) {
        await Future<void>.delayed(minimumDuration - elapsed);
      }

      state = state.copyWith(
        currentStep: SplashStep.complete,
        statusMessage: AppStrings.splashReadyMessage,
        isComplete: true,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          informationCollector: () sync* {
            yield ErrorDescription('Splash startup flow failed.');
          },
        ),
      );

      state = state.copyWith(
        currentStep: SplashStep.complete,
        statusMessage: AppStrings.splashFallbackMessage,
        isComplete: true,
      );
    }
  }
}

@immutable
class SplashFlowState {
  const SplashFlowState({
    required this.currentStep,
    required this.statusMessage,
    required this.bootstrapReady,
    required this.configReady,
    required this.authChecked,
    required this.isComplete,
  });

  const SplashFlowState.initial()
    : this(
        currentStep: SplashStep.bootstrap,
        statusMessage: AppStrings.splashBootstrapMessage,
        bootstrapReady: false,
        configReady: false,
        authChecked: false,
        isComplete: false,
      );

  final SplashStep currentStep;
  final String statusMessage;
  final bool bootstrapReady;
  final bool configReady;
  final bool authChecked;
  final bool isComplete;

  SplashFlowState copyWith({
    SplashStep? currentStep,
    String? statusMessage,
    bool? bootstrapReady,
    bool? configReady,
    bool? authChecked,
    bool? isComplete,
  }) {
    return SplashFlowState(
      currentStep: currentStep ?? this.currentStep,
      statusMessage: statusMessage ?? this.statusMessage,
      bootstrapReady: bootstrapReady ?? this.bootstrapReady,
      configReady: configReady ?? this.configReady,
      authChecked: authChecked ?? this.authChecked,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

enum SplashStep { bootstrap, config, auth, complete }
