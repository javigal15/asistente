import 'dart:convert';

import 'package:asistente/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> mesagges = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OpenIAAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              'content':
                  'Queres generar alguna imagen o arte por Inteligencia Artificial? $prompt . Responde simplemente SI o NO',
            }
          ],
        }),
      );
      print(res.body);
      // 200 siginifica que salio todo bien
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['mesagge']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes. ':
          case 'yes. ':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      {
        return ('Ocurrio un Error, probar nuevamente');
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    mesagges.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OpenIAAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": mesagges,
        }),
      );

      // 200 siginifica que salio todo bien
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['mesagge']['content'];
        content = content.trim();
        mesagges.add(
          {
            'role': 'asistente',
            'content': content,
          },
        );
        return content;
      }
      return ('Ocurrio un Error, probar nuevamente');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    mesagges.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OpenIAAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      // 200 siginifica que salio todo bien
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        mesagges.add(
          {
            'role': 'asistente',
            'content': imageUrl,
          },
        );
        return imageUrl;
      }
      return ('Ocurrio un Error, probar nuevamente');
    } catch (e) {
      return e.toString();
    }
  }
}
