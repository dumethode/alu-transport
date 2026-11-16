import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/pickup_point.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/pickup_points_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../cubit/setup_form_cubit.dart';
import '../widgets/pickup_option_tile.dart';
import '../widgets/role_toggle.dart';

/// Figma screen 2: first-time setup (name, role, pickup point, alerts).
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetupFormCubit>(
      create: (BuildContext context) => SetupFormCubit(),
      child: const _SetupView(),
    );
  }
}

class _SetupView extends StatefulWidget {
  const _SetupView();

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<AuthCubit>().state.user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final bool nameOk = _formKey.currentState?.validate() ?? false;
    final SetupFormCubit form = context.read<SetupFormCubit>();
    final bool choicesOk = form.validate();
    final AuthUser? user = context.read<AuthCubit>().state.user;
    if (!nameOk || !choicesOk || user == null) {
      return;
    }
    context.read<ProfileCubit>().createProfile(
      uid: user.uid,
      email: user.email,
      fullName: _name.text,
      role: form.state.role,
      pickupPointId: form.state.pickupPointId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (ProfileState previous, ProfileState current) =>
            current.errorMessage != null &&
            current.errorMessage != previous.errorMessage,
        listener: (BuildContext context, ProfileState state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.danger,
            ),
          );
          context.read<ProfileCubit>().clearMessages();
        },
        child: Form(
          key: _formKey,
          child: ResponsiveBody(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            children: <Widget>[
              const Text(
                'Set up your account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Text(
                'You only do this once.',
                style: TextStyle(color: context.mutedText),
              ),
              AppTextField(
                label: 'Full name',
                controller: _name,
                icon: AppIcons.user,
                validator: Validators.fullName,
              ),
              const _Label('I am a'),
              BlocBuilder<SetupFormCubit, SetupFormState>(
                buildWhen: (SetupFormState a, SetupFormState b) =>
                    a.role != b.role,
                builder: (BuildContext context, SetupFormState form) =>
                    RoleToggle(
                      value: form.role,
                      onChanged: context.read<SetupFormCubit>().chooseRole,
                    ),
              ),
              BlocBuilder<SetupFormCubit, SetupFormState>(
                builder: (BuildContext context, SetupFormState form) {
                  if (form.role == UserRole.driver) {
                    return const _DriverNote();
                  }
                  return _PickupSection(form: form);
                },
              ),
              BlocBuilder<SettingsCubit, AppSettings>(
                builder: (BuildContext context, AppSettings settings) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Bus alerts',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Tell me when the bus moves'),
                    value: settings.showAlertBanners,
                    onChanged: context
                        .read<SettingsCubit>()
                        .setShowAlertBanners,
                  );
                },
              ),
              BlocSelector<ProfileCubit, ProfileState, bool>(
                selector: (ProfileState state) => state.isSaving,
                builder: (BuildContext context, bool saving) => AppButton(
                  label: 'Continue',
                  isLoading: saving,
                  onPressed: _submit,
                ),
              ),
              TextButton(
                onPressed: context.read<AuthCubit>().signOut,
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickupSection extends StatelessWidget {
  const _PickupSection({required this.form});

  final SetupFormState form;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickupPointsCubit, PickupPointsState>(
      builder: (BuildContext context, PickupPointsState pickups) {
        final List<Widget> children = <Widget>[const _Label('My pickup point')];
        if (pickups.status != PickupPointsStatus.ready) {
          children.add(const SizedBox(height: 80, child: LoadingView()));
        } else if (pickups.points.isEmpty) {
          children.add(
            const MessageView(
              icon: AppIcons.mapPin,
              title: 'No pickup points yet',
              message:
                  'Pickup points appear after the driver signs in for the '
                  'first time. Try again in a moment.',
            ),
          );
        } else {
          for (final PickupPoint point in pickups.points) {
            children.add(
              PickupOptionTile(
                point: point,
                selected: point.id == form.pickupPointId,
                onTap: () =>
                    context.read<SetupFormCubit>().choosePickupPoint(point.id),
              ),
            );
          }
        }
        if (form.showPickupError) {
          children.add(
            const Text(
              'Choose the stop where you catch the bus',
              style: TextStyle(color: AppColors.danger, fontSize: 12.5),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: children,
        );
      },
    );
  }
}

class _DriverNote extends StatelessWidget {
  const _DriverNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppIcon(AppIcons.info, size: 18, color: AppColors.info),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Driver accounts must be approved by the ALU transport office. '
              'We check your email when you tap Continue.',
              style: TextStyle(color: AppColors.info, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: context.mutedText,
      ),
    );
  }
}
