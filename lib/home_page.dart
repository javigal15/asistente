import 'package:animate_do/animate_do.dart';
import 'package:asistente/feature_box.dart';
import 'package:asistente/openia_service.dart';
import 'package:asistente/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeech(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Asistente')),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ASISTENTE VIRTUAL
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40)
                      .copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20)
                        .copyWith(topLeft: Radius.zero),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      generatedContent == null
                          ? 'Hola! en que te puedo ayudar?'
                          : generatedContent!,
                      style: TextStyle(
                          color: Pallete.mainFontColor,
                          fontSize: generatedContent == null ? 25 : 18,
                          fontFamily: 'Cera Pro'),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            // Texto intermedio
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Acá hay algunos comandos',
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        fontSize: 20,
                        color: Pallete.mainFontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Suggestion List
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText:
                            'Obtiene información detallada sobre tu consulta'),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: 'Dall-E',
                        descriptionText:
                            'Obtiene información con búsqueda pontenciada de Dall-E'),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay * 2),
                    child: const FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Obtiene información de tu asistente personal'),
                  ),
                ],
              ),
            ),
            // Botón de microfono
            ZoomIn(
              delay: Duration(milliseconds: start + delay * 3),
              child: FloatingActionButton(
                backgroundColor: Pallete.firstSuggestionBoxColor,
                onPressed: () async {
                  if (await speechToText.hasPermission &&
                      speechToText.isNotListening) {
                    await startListening();
                  } else if (speechToText.isListening) {
                    final speech =
                        await openAIService.isArtPromptAPI(lastWords);
                    if (speech.contains('https')) {
                      generatedImageUrl = speech;
                      generatedContent = null;
                      setState(() {});
                    } else {
                      generatedImageUrl = null;
                      generatedContent = speech;
                      setState(() {});
                      await systemSpeech(speech);
                    }

                    await stopListening();
                  } else {
                    initSpeechToText();
                  }
                },
                child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
              ),
            )
          ],
        ),
      ),
    );
  }
}
