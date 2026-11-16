import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import '../../domain/entities/pickup_point.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/pickup_points_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/pickup_picker_sheet.dart';

/// Profile tab: avatar, name, pickup point, settings and sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, UserProfile profile) async {
    final ProfileCubit cubit = context.read<ProfileCubit>();
    final String? name = await showEditNameDialog(context, profile.fullName);
    if (name != null && name != profile.fullName) {
      await cubit.updateName(name);
    }
  }

  Future<void> _changePickup(BuildContext context, UserProfile profile) async {
    final ProfileCubit cubit = context.read<ProfileCubit>();
    final List<PickupPoint> points = context
        .read<PickupPointsCubit>()
        .state
        .points;
    final String? id = await showPickupPickerSheet(
      context,
      points: points,
      selectedId: profile.pickupPointId,
    );
    if (id != null && id != profile.pickupPointId) {
      await cubit.updatePickupPoint(id);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final AuthCubit auth = context.read<AuthCubit>();
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again at any time.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (yes ?? false) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (ProfileState previous, ProfileState current) =>
            (current.errorMessage ?? current.infoMessage) != null &&
            (current.errorMessage != previous.errorMessage ||
                current.infoMessage != previous.infoMessage),
        listener: (BuildContext context, ProfileState state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? state.infoMessage!),
              backgroundColor: state.errorMessage != null
                  ? AppColors.danger
                  : AppColors.primaryDark,
            ),
          );
          context.read<ProfileCubit>().clearMessages();
        },
        builder: (BuildContext context, ProfileState state) {
          final UserProfile? profile = state.profile;
          if (profile == null) {
            return const LoadingView();
          }
          final PickupPoint? pickup = context
              .watch<PickupPointsCubit>()
              .state
              .byId(profile.pickupPointId);
          return ResponsiveBody(
            children: <Widget>[
              AppCard(
                child: Column(
                  children: <Widget>[
                    UserAvatar(seed: profile.avatarSeed, size: 92),
                    const SizedBox(height: 12),
                    Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.mutedText),
                    ),
                    const SizedBox(height: 10),
                    StatusPill(
                      label: profile.isDriver ? 'Driver' : 'Student',
                      icon: profile.isDriver ? AppIcons.bus : AppIcons.user,
                      foreground: AppColors.primaryDark,
                      background: AppColors.primaryLight,
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Shuffle avatar',
                      icon: AppIcons.shuffle,
                      variant: AppButtonVariant.outline,
                      isLoading: state.isSaving,
                      onPressed: context.read<ProfileCubit>().shuffleAvatar,
                    ),
                  ],
                ),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    _ProfileRow(
                      icon: AppIcons.pencil,
                      title: 'Edit name',
                      subtitle: profile.fullName,
                      onTap: () => _editName(context, profile),
                    ),
                    if (!profile.isDriver) ...<Widget>[
                      const Divider(),
                      _ProfileRow(
                        icon: AppIcons.mapPin,
                        title: 'Pickup point',
                        subtitle: pickup?.name ?? 'Not chosen',
                        onTap: () => _changePickup(context, profile),
                      ),
                    ],
                    const Divider(),
                    _ProfileRow(
                      icon: AppIcons.settings,
                      title: 'Settings',
                      subtitle: 'Theme, time format, alerts, text size',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Sign out',
                icon: AppIcons.logOut,
                variant: AppButtonVariant.danger,
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppIcons icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 56,
      leading: AppIcon(icon, color: context.colors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: AppIcon(
        AppIcons.chevronRight,
        size: 18,
        color: context.mutedText,
      ),
      onTap: onTap,
    );
  }
}
