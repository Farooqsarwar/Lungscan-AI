import 'package:flutter/material.dart';

class LungCancerRiskFactorsScreen extends StatelessWidget {
  const LungCancerRiskFactorsScreen({Key? key}) : super(key: key);

  // List of lung cancer risk factors with emoji, title, and description
  final List<Map<String, String>> riskFactors = const [
    {
      'emoji': '🚬',
      'title': 'Smoking',
      'description':
      'Smoking tobacco is the leading cause of lung cancer, responsible for about 85% of cases. Both active smoking and exposure to secondhand smoke significantly increase your risk.',
    },
    {
      'emoji': '🌫️',
      'title': 'Secondhand Smoke',
      'description':
      'Regular exposure to secondhand smoke, such as living with a smoker, can raise your lung cancer risk by 20-30%, even if you don’t smoke yourself.',
    },
    {
      'emoji': '🏠',
      'title': 'Radon Gas',
      'description':
      'Radon, a naturally occurring radioactive gas, can accumulate in homes and buildings. Long-term exposure is the second-leading cause of lung cancer after smoking.',
    },
    {
      'emoji': '🏭',
      'title': 'Asbestos Exposure',
      'description':
      'Working with asbestos (common in construction or shipbuilding) increases lung cancer risk, especially if you’re a smoker. Asbestos fibers can irritate lung tissue over time.',
    },
    {
      'emoji': '🌍',
      'title': 'Air Pollution',
      'description':
      'Living in areas with high levels of air pollution, such as from vehicle exhaust or industrial emissions, can slightly elevate your lung cancer risk over time.',
    },
    {
      'emoji': '👨‍👩‍👧',
      'title': 'Family History',
      'description':
      'A family history of lung cancer may increase your risk due to genetic factors. If a close relative had lung cancer, consider regular screenings.',
    },
    {
      'emoji': '🩺',
      'title': 'Personal History of Lung Disease',
      'description':
      'Previous lung conditions like chronic obstructive pulmonary disease (COPD) or tuberculosis can scar lung tissue, raising your risk of developing lung cancer.',
    },
    {
      'emoji': '☢️',
      'title': 'Radiation Exposure',
      'description':
      'Past radiation therapy to the chest (e.g., for breast cancer or lymphoma) can increase lung cancer risk, especially if you’re a smoker.',
    },
    {
      'emoji': '⚒️',
      'title': 'Occupational Hazards',
      'description':
      'Exposure to carcinogens like arsenic, diesel exhaust, or silica in workplaces (e.g., mining or manufacturing) can contribute to lung cancer over time.',
    },
    {
      'emoji': '🕰️',
      'title': 'Age Factor',
      'description':
      'Lung cancer risk increases with age, with most cases diagnosed in people over 65. Regular screenings are crucial as you get older.',
    },
    {
      'emoji': '🍔',
      'title': 'Poor Diet',
      'description':
      'A diet low in fruits and vegetables may increase lung cancer risk. Antioxidants in these foods help protect lung cells from damage.',
    },
    {
      'emoji': '🛋️',
      'title': 'Lack of Physical Activity',
      'description':
      'A sedentary lifestyle can indirectly contribute to lung cancer risk by affecting overall health. Regular exercise supports lung function and immunity.',
    },
    {
      'emoji': '🍷',
      'title': 'Alcohol Consumption',
      'description':
      'Heavy alcohol use may increase lung cancer risk, particularly when combined with smoking. Limit intake to moderate levels (1-2 drinks per day).',
    },
    {
      'emoji': '🧬',
      'title': 'Genetic Mutations',
      'description':
      'Certain genetic mutations, like EGFR or KRAS mutations, can predispose you to lung cancer. Genetic testing may help identify your risk.',
    },
    {
      'emoji': '🔥',
      'title': 'Chronic Inflammation',
      'description':
      'Chronic inflammation in the lungs from infections or autoimmune diseases can lead to cellular changes that increase lung cancer risk over time.',
    },
    {
      'emoji': '🚛',
      'title': 'Exposure to Diesel Exhaust',
      'description':
      'Long-term exposure to diesel exhaust, common for truck drivers or mechanics, can irritate the lungs and elevate lung cancer risk.',
    },
    {
      'emoji': '🩻',
      'title': 'Previous Cancer History',
      'description':
      'A history of other cancers (e.g., head, neck, or esophageal cancer) may increase your lung cancer risk, especially if you smoked.',
    },
    {
      'emoji': '🦠',
      'title': 'HIV/AIDS',
      'description':
      'People with HIV/AIDS have a higher risk of lung cancer due to weakened immunity and higher rates of smoking in this population.',
    },
    {
      'emoji': '💊',
      'title': 'Beta-Carotene Supplements',
      'description':
      'High doses of beta-carotene supplements may increase lung cancer risk in smokers. Get nutrients from whole foods instead of supplements.',
    },
    {
      'emoji': '🏙️',
      'title': 'Environmental Toxins',
      'description':
      'Exposure to environmental toxins like coal products, talc, or uranium can contribute to lung cancer risk, especially in high-risk occupations.',
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
                  'Lung Cancer Risk Factors',
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
                  itemCount: riskFactors.length,
                  itemBuilder: (context, index) {
                    final factor = riskFactors[index];
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
                                factor['emoji']!,
                                style: TextStyle(fontSize: 24),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      factor['title']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      factor['description']!,
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