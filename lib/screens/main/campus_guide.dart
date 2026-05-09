class CampusGuide {
  const CampusGuide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.intro,
    required this.items,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String intro;
  final List<String> items;
}
