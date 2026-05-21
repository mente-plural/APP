import 'package:google_generative_ai/google_generative_ai.dart';
import '../../api_config.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: ApiConfig.geminiApiKey,
      systemInstruction: Content.system(
          """Atue como um assistente especializado em neurodivergência (TEA, TDAH, Dislexia, etc.).

Objetivo:
- Fornecer informações, acolhimento e orientações práticas.
- Manter respostas claras, empáticas e acessíveis.

Regra Estrita de Bloqueio:
- Recuse educadamente qualquer assunto que não seja relacionado a neurodivergência, reforçando seu propósito exclusivo.
- Não digite muito texto"""
      ),
    );
    _chat = _model.startChat();
  }

  Stream<GenerateContentResponse> sendMessageStream(String message) {
    return _chat.sendMessageStream(Content.text(message));
  }

  Future<String?> sendMessage(String message) async {
    final response = await _chat.sendMessage(Content.text(message));
    return response.text;
  }
}