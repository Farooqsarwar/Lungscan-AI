import 'package:flutter/material.dart';

class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({Key? key}) : super(key: key);

  // List of health tips with emoji, title, and description
  final List<Map<String, String>> healthTips = const [
    {
      'emoji': '💧',
      'title': 'Hydration',
      'description':
      'Drink at least 8-10 glasses of water daily (about 2 liters) to stay hydrated. Proper hydration supports digestion, keeps your skin glowing, and helps your body function optimally.',
    },
    {
      'emoji': '😴',
      'title': 'Sleep Quality',
      'description':
      'Aim for 7-9 hours of uninterrupted sleep each night. Create a bedtime routine, avoid screens before bed, and keep your room dark to improve sleep quality and mental health.',
    },
    {
      'emoji': '🏃‍♂️',
      'title': 'Regular Exercise',
      'description':
      'Engage in at least 150 minutes of moderate exercise weekly, like brisk walking, swimming, or yoga. Exercise boosts heart health, strengthens muscles, and uplifts your mood.',
    },
    {
      'emoji': '🥗',
      'title': 'Balanced Diet',
      'description':
      'Include a variety of fruits, vegetables, lean proteins, and whole grains in your meals. A balanced diet provides essential nutrients, supports immunity, and reduces disease risk.',
    },
    {
      'emoji': '🧘‍♀️',
      'title': 'Stress Management',
      'description':
      'Practice mindfulness or meditation for 10-15 minutes daily. Techniques like deep breathing or journaling can reduce stress, improve focus, and enhance emotional well-being.',
    },
    {
      'emoji': '📱',
      'title': 'Screen Time',
      'description':
      'Limit screen time to less than 2 hours before bedtime. Blue light from devices can disrupt sleep patterns, so use blue light filters or take breaks to rest your eyes.',
    },
    {
      'emoji': '🚭',
      'title': 'Quit Smoking',
      'description':
      'Stop smoking to lower your risk of lung cancer, heart disease, and stroke. Seek support through counseling or nicotine replacement therapies to make quitting easier.',
    },
    {
      'emoji': '🧴',
      'title': 'Sun Protection',
      'description':
      'Apply sunscreen with SPF 30 or higher every day, even on cloudy days. Wear protective clothing and sunglasses to shield your skin and eyes from harmful UV rays.',
    },
    {
      'emoji': '🧍‍♂️',
      'title': 'Posture Correction',
      'description':
      'Maintain good posture by keeping your back straight and shoulders relaxed. Proper posture prevents back pain, improves breathing, and boosts confidence.',
    },
    {
      'emoji': '🧠',
      'title': 'Mental Health Support',
      'description':
      'Schedule regular check-ins with a therapist or talk to a trusted friend. Addressing mental health concerns early can prevent anxiety, depression, and burnout.',
    },
    {
      'emoji': '🪥',
      'title': 'Oral Hygiene',
      'description':
      'Brush your teeth twice daily for 2 minutes and floss once a day. Good oral hygiene prevents cavities, gum disease, and bad breath, contributing to overall health.',
    },
    {
      'emoji': '⚖️',
      'title': 'Weight Management',
      'description':
      'Maintain a healthy weight by balancing calorie intake with physical activity. A healthy BMI reduces the risk of diabetes, heart disease, and joint problems.',
    },
    {
      'emoji': '🩺',
      'title': 'Blood Pressure Monitoring',
      'description':
      'Check your blood pressure regularly, aiming for readings below 120/80 mmHg. Manage it with a low-sodium diet, exercise, and stress reduction to protect your heart.',
    },
    {
      'emoji': '🥕',
      'title': 'Fiber Intake',
      'description':
      'Consume 25-30 grams of dietary fiber daily from sources like oats, beans, and vegetables. Fiber aids digestion, lowers cholesterol, and helps control blood sugar.',
    },
    {
      'emoji': '☀️',
      'title': 'Vitamin D Intake',
      'description':
      'Get 15-20 minutes of sunlight exposure daily or take a vitamin D supplement (800-1000 IU). Vitamin D strengthens bones, boosts immunity, and improves mood.',
    },
    {
      'emoji': '👥',
      'title': 'Social Connections',
      'description':
      'Spend quality time with friends and family at least once a week. Strong social bonds reduce stress, improve happiness, and lower the risk of loneliness-related issues.',
    },
    {
      'emoji': '🧼',
      'title': 'Hand Hygiene',
      'description':
      'Wash your hands with soap for 40-60 seconds, especially before eating or after touching public surfaces. This prevents the spread of germs and infections.',
    },
    {
      'emoji': '💉',
      'title': 'Vaccinations',
      'description':
      'Stay up to date on vaccinations, including annual flu shots and recommended boosters. Vaccines protect against preventable diseases like influenza and pneumonia.',
    },
    {
      'emoji': '☕',
      'title': 'Caffeine Moderation',
      'description':
      'Limit caffeine intake to 400 mg per day (about 4 cups of coffee). Excessive caffeine can cause anxiety, insomnia, and heart palpitations, so monitor your consumption.',
    },
    {
      'emoji': '🏥',
      'title': 'Annual Checkups',
      'description':
      'Schedule annual health checkups with your doctor to monitor key metrics like blood pressure, cholesterol, and glucose levels. Early detection can prevent serious health issues.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 50),
            SizedBox(width: 10),
          ],
        ),
        backgroundColor: Color(0xFF184542),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF184542),
              Color(0xFF6AB4BC),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Daily Routine Health Tips',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: healthTips.length,
                  itemBuilder: (context, index) {
                    final tip = healthTips[index];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['emoji']!,
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tip['title']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      tip['description']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}