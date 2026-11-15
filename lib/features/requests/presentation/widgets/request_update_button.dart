import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/update_request.dart';
import '../cubit/student_request_cubit.dart';

/// "Request update" on the student home. Turns into "Cancel request"
/// while the request is waiting for the driver.
class RequestUpdateButton extends StatelessWidget {
  const RequestUpdateButton({
    super.key,
    required this.roundId,
    required this.pickupPointId,
  });

  final String roundId;
  final String? pickupPointId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentRequestCubit, StudentRequestState>(
      listenWhen: (StudentRequestState previous, StudentRequestState current) =>
          current.message != null && current.message != previous.message,
      listener: (BuildContext context, StudentRequestState state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
        context.read<StudentRequestCubit>().clearMessage();
      },
      builder: (BuildContext context, StudentRequestState state) {
        final StudentRequestCubit cubit = context.read<StudentRequestCubit>();
        final UpdateRequest? open = state.openFor(roundId);
        if (open != null) {
          return AppButton(
            label: 'Cancel request',
            icon: AppIcons.x,
            variant: AppButtonVariant.outline,
            onPressed: () => cubit.cancel(open.id),
          );
        }
        return AppButton(
          label: 'Request update',
          icon: AppIcons.messageCircle,
          variant: AppButtonVariant.outline,
          isLoading: state.isSending,
          onPressed: () => cubit.requestUpdate(
            roundId: roundId,
            pickupPointId: pickupPointId,
          ),
        );
      },
    );
  }
}
