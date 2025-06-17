import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection_container.dart' as di;
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';
import '../widgets/profile_form_widget.dart';

class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserProfileCubit>()..loadProfile(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocListener<UserProfileCubit, UserProfileState>(
          listener: (context, state) {
            if (state is UserProfileSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil guardado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pushReplacementNamed('/dashboard');
            } else if (state is UserProfileDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil eliminado exitosamente'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is UserProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const ProfileFormWidget(),
        ),
      ),
    );
  }
}
