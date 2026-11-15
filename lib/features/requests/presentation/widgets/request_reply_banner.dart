import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/update_request.dart';
import '../cubit/student_request_cubit.dart';

/// Shows the driver's latest reply to the student's request.
class RequestReplyBanner extends StatelessWidget {
  const RequestReplyBanner({super.key, required this.roundId});

  final String roundId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentRequestCubit, StudentRequestState>(
      builder: (BuildContext context, StudentRequestState state) {
        final UpdateRequest? answer = state.latestAnswerFor(roundId);
        if (answer == null || answer.reply == null) {
          return const SizedBox.shrink();
        }
        final DateTime? at = answer.answeredAt;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Row(
            children: <Widget>[
              const AppIcon(
                AppIcons.messageCircle,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Driver replied: "${answer.reply}"'
                  '${at == null ? '' : ' · ${Formatters.timeAgo(at)}'}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
