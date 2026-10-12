import 'package:nylo_framework/nylo_framework.dart';

/* Login Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/7.x/forms#how-it-works
| Casts: https://nylo.dev/docs/7.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/7.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class LoginForm extends NyFormWidget {
  const LoginForm({
    super.key,
    super.header,
    super.footer,
    super.submitButton,
    super.crossAxisSpacing,
    super.onSubmit,
    super.onFailure,
    String? name,
  }) : super(name: name ?? "login");

  @override
  fields() => [
        Field.email(
          "Email",
          validator: FormValidator.email(),
        ),
        Field.password(
          "Password",
          viewable: true,
          validator: FormValidator.password(strength: 1),
        ),
      ];

  static NyFormActions get actions => const NyFormActions("login");
}
