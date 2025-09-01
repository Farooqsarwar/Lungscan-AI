import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Chatbot extends StatefulWidget {
  final String? initialQuery;

  const Chatbot({super.key, this.initialQuery});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isModelInitialized = false;
  GenerativeModel? _model;
  ChatSession? _chat;

  @override
  void initState() {
    super.initState();
    _initializeModel().then((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _handleSubmitted(widget.initialQuery!);
      }
    });
  }

  Future<void> _initializeModel() async {
    try {
      const apiKey = "AIzaSyCuUj8UFsH6GsWXxPcxzO4Koy8XUWjfjtA";
      if (apiKey.isEmpty) {
        throw Exception('Please set your Google AI API key');
      }

      _model = GenerativeModel(
        model: 'gemini-2.0-flash', // Free tier model
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 1000, // Reduced to stay within limits
          temperature: 0.7,
          topP: 0.9,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      // Test the API key with a simple request
      final testResponse = await _model!.generateContent([
        Content.text("Hello")
      ]);

      if (testResponse.text == null) {
        throw Exception('API key test failed - no response received');
      }

      _chat = _model?.startChat(
        history: [
          Content.text(
              "You are a helpful health assistant. Specialize in medical, wellness, and health-related topics. "
                  "Be concise but accurate. For non-health questions, politely redirect to health topics. "
                  "Always remind users to consult healthcare professionals for serious medical concerns."),
        ],
      );

      setState(() {
        _isModelInitialized = true;
      });
    } catch (e) {
      debugPrint('Model initialization error: $e');
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Failed to initialize AI service. Please check your API key and internet connection.",
            isUser: false,
          ),
        );
      });
    }
  }

  Future<bool> _isHealthRelated(String text) async {
    if (!_isModelInitialized || _model == null) return false;

    try {
      // Create a separate model instance for content checking to avoid interfering with chat
      final checkModel = GenerativeModel(
        model: 'gemini-1.5-flash', // Free tier model
        apiKey: "AIzaSyCzoGa35PSsLQp39BjNMUfQhnuM23Uwfm8", // Your existing API key
      );

      final prompt = """
      Analyze if this input is health-related (medical, wellness, fitness, nutrition, mental health) or a general greeting.
      Respond ONLY with "health", "greeting", or "other":
      
      "$text"
      """;

      final response = await checkModel.generateContent([Content.text(prompt)]);
      final responseText = response.text?.toLowerCase().trim() ?? 'other';

      return responseText.contains('health') || responseText.contains('greeting');
    } catch (e) {
      debugPrint('Content check error: $e');
      // If content check fails, allow the message through to avoid blocking legitimate health queries
      return true;
    }
  }

  void _handleSubmitted(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (!_isModelInitialized || _chat == null) {
      _showError("AI service is not ready. Please wait or restart the app.");
      return;
    }

    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text: trimmedText, isUser: true));
      _isLoading = true;
    });

    try {
      final isRelevant = await _isHealthRelated(trimmedText);

      if (!isRelevant) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: "I specialize in health topics. Ask me about nutrition, "
                  "fitness, medical conditions, mental health, or general wellness advice!",
              isUser: false,
            ),
          );
          _isLoading = false;
        });
        return;
      }

      final response = await _chat!.sendMessage(Content.text(trimmedText));
      final responseText = response.text ?? 'Sorry, I couldn\'t process that. Please try rephrasing your question.';

      setState(() {
        _messages.insert(0, ChatMessage(text: responseText, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _handleSubmitted: $e');
      String errorMessage = "I'm having trouble processing your request. ";

      if (e.toString().contains('API_KEY')) {
        errorMessage += "Please check the API key configuration.";
      } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
        errorMessage += "API quota exceeded. Please try again later.";
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage += "Please check your internet connection.";
      } else {
        errorMessage += "Please try again.";
      }

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: errorMessage,
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: message,
          isUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 50),
          ],
        ),
        backgroundColor: const Color(0xFF184542),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF184542),
              Color(0xFF6AB4BC),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Chatbot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeMessage()
                  : ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) => _messages[index],
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_sharp,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              "Welcome to Chatbot!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Ask me about nutrition, fitness, wellness, or any health-related questions.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF184542),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4D6160),
                        Color(0xFF3B6265),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: _textController,
                            enabled: _isModelInitialized && !_isLoading,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: _isModelInitialized
                                  ? 'Ask a health question...'
                                  : 'Initializing AI...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 12.0,
                              ),
                            ),
                            onSubmitted: _handleSubmitted,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _isModelInitialized && !_isLoading
                              ? () => _handleSubmitted(_textController.text)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.medical_services, color: Color(0xFF184542)),
              ),
            ),
          Flexible(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4D6160),
                      Color(0xFF3B6265),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'You' : 'Health AI',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF184542)),
              ),
            ),
        ],
      ),
    );
  }
}