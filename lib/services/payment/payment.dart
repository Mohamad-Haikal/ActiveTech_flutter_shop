// import 'dart:convert';

// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_stripe/flutter_stripe.dart';

// class StripeTransactionResponse {
//   String message;
//   bool success;
//   StripeTransactionResponse({required this.message, required this.success});
// }

// class StripeServices {
//   static String apiBase = 'https://apu.stripe.com/v1';
//   static String paymentApiUrl = '${StripeServices.apiBase}/payment_intents';
//   static Uri paymentApiUri = Uri.parse(apiBase);
//   static String secret = 'sk_test_51MiOFqCca33SRveICK6yEM7AqPXhbRVxtWgkkDm7K8dYZ79CbWWr4aAVII7fxExduvgxmDkSQSjmn9ukjXF6Crfg00nZwSM6of';

//   static Map<String, String> headers = {'Authorization': 'Bearer ${StripeServices.secret}', 'Content-Type': 'application/x-www-form-urlencoded'};

//   static init() {
//     .setOptions(
//       StripeOptions(
//           publishableKey: 'pk_test_51MiOFqCca33SRveIuZm72WKFdLGpiCkhd1pSQmEwoG4Xx77er6L9PzylrmpF6FjyymyG6kdcHJk65Q2w3TUjHvLn00CGSDcEvI',
//           androidPayMode: 'test',
//           merchantId: 'test'),
//     );
//   }

//   static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//       };
//       var response = await http.post(paymentApiUri, headers: headers, body: body);
//       return jsonDecode(response.body);
//     } catch (e) {
//       print('this error have happend = $e');
//       throw 'error';
//     }
//   }

//   static Future<StripeTransactionResponse> paymentMethod({required String amount, required String currency}) async {
//     try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
//       var paymentIntent = await StripeServices.createPaymentIntent(amount, currency);
//       var response =
//           await StripePayment.confirmPaymentIntent(PaymentIntent(clientSecret: paymentIntent['client_secret'], paymentMethodId: paymentMethod.id));

//       if (response.status == 'succeeded') {
//         return StripeTransactionResponse(message: 'Transaction succeful', success: true);
//       } else {
//         return StripeTransactionResponse(message: 'Transaction failed', success: false);
//       }
//     } catch (error) {
//       return StripeTransactionResponse(message: 'Transaction failed', success: false);
//     } on PlatformException catch (error) {
//       return StripeServices.getErrorAndAnalyze(error);
//     }
//   }

//   static getErrorAndAnalyze(error) {
//     String message = 'Something went wrong';
//     if (error.code == 'canceled') {
//       message = 'Transaction canceled';
//     }
//     return StripeTransactionResponse(message: message, success: false);
//   }
// }
