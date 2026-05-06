import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch the auth provider so the redirect listener (in app_router) sees
    // a definitive AsyncData state ASAP.
    ref.watch(authProvider);

    return const Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/images/logoAMBIS.png'),
                height: 120,
              ),
              SizedBox(height: Spacing.md),
              Text(
                'SMAN 07 Kabupaten Tangerang',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              SizedBox(height: Spacing.lg),
              CircularProgressIndicator(color: AppColors.darkAccent),
            ],
          ),
        ),
      ),
    );
  }
}
