import 'package:nylo_framework/nylo_framework.dart';

/* Register Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/7.x/forms#how-it-works
| Casts: https://nylo.dev/docs/7.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/7.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class RegisterForm extends NyFormWidget {
  RegisterForm({
    super.key,
    super.header,
    super.footer,
    super.submitButton,
    super.crossAxisSpacing,
    super.onSubmit,
    super.onFailure,
    String? name,
  }) : super(name: name ?? "register");

  @override
  fields() => [
        // A list renders its fields side by side, like the two-column row the
        // registration page used before.
        [
          Field.text(
            "First Name",
            autofocus: true,
          ),
          Field.text(
            "Last Name",
          ),
        ],
        Field.email(
          "Email",
          label: "Email address",
          validator: FormValidator.email(),
        ),
        Field.password(
          "Password",
          viewable: true,
          validator: FormValidator.password(strength: 1),
        ),
      ];

  static NyFormActions get actions => const NyFormActions("register");
}
