import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/cubits/auth_cubit/auth_cubit.dart';
import 'package:jupyter_health/domain/entity/user.dart';

class UserWrapper extends StatelessWidget {
  final Widget Function(User user, String accessToken, String refreshToken)
  builder;
  const UserWrapper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) => authState.maybeMap(
        authenticated: (value) =>
            builder(value.user, value.accessToken, value.refreshToken),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
