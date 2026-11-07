import 'dart:convert';
import 'dart:io';

const _topics = <String>[
  'Ancient Trade Routes|Indian History|Hard',
  'The Mauryan Administration|Indian History|Medium',
  'The Gupta Age of Learning|Indian History|Medium',
  'Medieval Water Systems|Indian History|Easy',
  'The Freedom Movement Press|Indian History|Hard',
  'Tribal Resistance in India|Indian History|Medium',
  'India’s Maritime Heritage|Indian History|Medium',
  'The Making of the Constitution|Indian History|Hard',
  'Historic Town Planning|Indian History|Easy',
  'Women in the National Movement|Indian History|Medium',
  'The Himalayan Watersheds|Indian Geography|Hard',
  'The Thar Desert Landscape|Indian Geography|Easy',
  'Coastal Plains and Ports|Indian Geography|Medium',
  'Monsoon Patterns in India|Indian Geography|Hard',
  'River Basin Management|Indian Geography|Medium',
  'The Deccan Plateau|Indian Geography|Easy',
  'Island Ecosystems|Indian Geography|Medium',
  'Urban Heat Islands|Indian Geography|Hard',
  'Soil Conservation|Indian Geography|Easy',
  'Parliamentary Debate|Indian Polity|Medium',
  'The Federal Structure|Indian Polity|Hard',
  'Local Self Government|Indian Polity|Easy',
  'Fundamental Rights|Indian Polity|Medium',
  'Public Accountability|Indian Polity|Hard',
  'The Election Process|Indian Polity|Easy',
  'Independent Institutions|Indian Polity|Hard',
  'Citizen Participation|Indian Polity|Medium',
  'Access to Justice|Indian Polity|Medium',
  'Household Savings|Indian Economy|Easy',
  'Agricultural Markets|Indian Economy|Medium',
  'Small Enterprise Finance|Indian Economy|Hard',
  'Public Infrastructure|Indian Economy|Medium',
  'Financial Inclusion|Indian Economy|Easy',
  'Price Stability|Indian Economy|Hard',
  'Skills and Employment|Indian Economy|Medium',
  'Cooperative Institutions|Indian Economy|Easy',
  'Export Competitiveness|Indian Economy|Hard',
  'The Scientific Method|Science and Technology|Easy',
  'Space-Based Observation|Science and Technology|Medium',
  'Renewable Energy Storage|Science and Technology|Hard',
  'Public Health Research|Science and Technology|Medium',
  'Materials in Everyday Life|Science and Technology|Easy',
  'Robotics and Safety|Science and Technology|Hard',
  'Measurement and Standards|Science and Technology|Medium',
  'Agricultural Innovation|Science and Technology|Easy',
  'Cybersecurity Basics|Science and Technology|Hard',
  'Wetland Conservation|Environment and Biodiversity|Medium',
  'Forest Corridors|Environment and Biodiversity|Hard',
  'Pollinator Diversity|Environment and Biodiversity|Easy',
  'Waste Reduction|Environment and Biodiversity|Easy',
  'Climate Resilience|Environment and Biodiversity|Hard',
  'Clean Air Planning|Environment and Biodiversity|Medium',
  'Community Water Stewardship|Environment and Biodiversity|Medium',
  'Marine Conservation|Environment and Biodiversity|Hard',
  'Native Plant Restoration|Environment and Biodiversity|Easy',
  'Reading for Understanding|Education|Easy',
  'Teacher Development|Education|Medium',
  'Libraries as Learning Centres|Education|Easy',
  'Assessment and Feedback|Education|Hard',
  'Inclusive Classrooms|Education|Medium',
  'Vocational Education|Education|Medium',
  'Digital Learning Resources|Education|Hard',
  'Learning Through Projects|Education|Easy',
  'Language and Communication|Education|Medium',
  'Public Health Awareness|Social Development|Easy',
  'Nutrition and Wellbeing|Social Development|Medium',
  'Safe Public Spaces|Social Development|Hard',
  'Disability Inclusion|Social Development|Medium',
  'Community Volunteerism|Social Development|Easy',
  'Affordable Housing|Social Development|Hard',
  'Women’s Economic Participation|Social Development|Medium',
  'Youth Leadership|Social Development|Easy',
  'Social Security Delivery|Social Development|Hard',
  'India’s Cultural Diversity|General Awareness|Easy',
  'Museums and Memory|General Awareness|Medium',
  'Sportsmanship and Teamwork|General Awareness|Easy',
  'National Symbols and Civic Respect|General Awareness|Medium',
  'Scientific Temper|General Awareness|Hard',
  'Public Service Ethics|General Awareness|Medium',
  'Disaster Preparedness|General Awareness|Hard',
  'Maps and Public Information|General Awareness|Easy',
  'The Value of Census Data|General Awareness|Medium',
  'Digital Public Services|Technology and Digital India|Medium',
  'Accessible Digital Design|Technology and Digital India|Hard',
  'Digital Payments Literacy|Technology and Digital India|Easy',
  'Open Data for Citizens|Technology and Digital India|Medium',
  'Responsible Artificial Intelligence|Technology and Digital India|Hard',
  'Rural Connectivity|Technology and Digital India|Easy',
  'Data Privacy|Technology and Digital India|Hard',
  'Online Learning Communities|Technology and Digital India|Medium',
  'Technology in Public Libraries|Technology and Digital India|Easy',
  'Personal Discipline|Ethics, Discipline, and National Development|Easy',
  'Integrity in Daily Work|Ethics, Discipline, and National Development|Medium',
  'The Habit of Preparation|Ethics, Discipline, and National Development|Easy',
  'Respectful Communication|Ethics, Discipline, and National Development|Medium',
  'Leadership Through Service|Ethics, Discipline, and National Development|Hard',
  'Time Management|Ethics, Discipline, and National Development|Easy',
  'Careful Decision Making|Ethics, Discipline, and National Development|Hard',
  'Shared Responsibility|Ethics, Discipline, and National Development|Medium',
  'Learning from Mistakes|Ethics, Discipline, and National Development|Easy',
];

void main() {
  final now = DateTime.utc(2026, 10, 31).toIso8601String();
  final passages = <Map<String, Object?>>[];
  for (var i = 0; i < _topics.length; i++) {
    final fields = _topics[i].split('|');
    final content = _content(fields[0], fields[1], i);
    passages.add({
      'id': 'twyp-${(i + 1).toString().padLeft(3, '0')}',
      'title': fields[0],
      'category': fields[1],
      'difficulty': fields[2],
      'content': content,
      'word_count': _words(content),
      'character_count': content.length,
      'estimated_typing_duration': 8,
      'language': 'English',
      'source_type': 'bundled',
      'created_at': now,
      'updated_at': now,
      'is_custom': 0,
      'version': 1,
    });
  }
  final file = File('assets/data/passages.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(passages));
  stdout.writeln(
    'Generated ${passages.length} passages: ${passages.map((p) => p['word_count']).reduce((a, b) => (a as int) + (b as int))} total words.',
  );
}

int _words(String s) =>
    RegExp(r"[A-Za-z0-9]+(?:['’-][A-Za-z0-9]+)?").allMatches(s).length;
String _content(String title, String category, int index) {
  const actions = [
    'careful observation',
    'patient comparison',
    'open discussion',
    'accurate record keeping',
    'regular review',
    'practical planning',
    'thoughtful questioning',
    'responsible action',
    'clear communication',
    'steady follow-through',
  ];
  const groups = [
    'students',
    'workers',
    'families',
    'local institutions',
    'research teams',
    'community groups',
    'public servants',
    'small businesses',
    'teachers',
    'young citizens',
  ];
  const values = [
    'fairness',
    'precision',
    'resilience',
    'cooperation',
    'curiosity',
    'accountability',
    'prudence',
    'inclusion',
    'continuity',
    'initiative',
  ];
  const outcomes = [
    'better decisions',
    'durable public confidence',
    'useful local knowledge',
    'measurable improvement',
    'safer daily routines',
    'shared understanding',
    'responsible innovation',
    'balanced progress',
    'long-term capacity',
    'practical solutions',
  ];
  final p = <String>[];
  final blocks = _words(title) >= 5 ? 9 : 10;
  for (var block = 0; block < blocks; block++) {
    final n = block;
    final a = actions[(n + index) % actions.length],
        g = groups[(n * 3 + index) % groups.length],
        v = values[(n * 7 + index) % values.length],
        o = outcomes[(n * 9 + index) % outcomes.length];
    p.add(
      'For $title, $g apply $a; $title therefore connects evidence with $v. A $title review compares local experience, reliable records, and clearly stated limits before any conclusion is announced. When $title raises a question, $g identify opportunities, explain choices plainly, and record the reason for each change. In $title work, a practical plan names responsibilities, dates, and resources; $title also requires a later review of results. By treating $title with care, $g build $o and leave useful lessons for the next decision.',
    );
  }
  return p.join('\n\n');
}
