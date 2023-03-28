import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCreditCardForm extends StatefulWidget {
  const AddCreditCardForm({
    Key? key,
  }) : super(key: key);

  @override
  _AddCreditCardFormState createState() => _AddCreditCardFormState();
}

class _AddCreditCardFormState extends State<AddCreditCardForm> {
  Map<String, dynamic>? paymentIntent;

  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  late Function(CreditCardModel) onCreditCardModelChange;
  late Color themeColor;
  late GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return CreditCardForm(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      cvvCode: cvvCode,
      onCreditCardModelChange: onCreditCardModelChange,
      themeColor: themeColor,
      formKey: formKey,
    );
  }
}
