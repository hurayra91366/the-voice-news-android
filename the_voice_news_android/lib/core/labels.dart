class Labels {
  final String language;
  const Labels(this.language);
  bool get bn => language == 'bn';
  String get latest => bn ? 'সর্বশেষ সংবাদ' : 'Latest News';
  String get search => bn ? 'সংবাদ খুঁজুন' : 'Search News';
  String get saved => bn ? 'সংরক্ষিত' : 'Saved';
  String get videos => bn ? 'ভিডিও' : 'Videos';
  String get live => bn ? 'সরাসরি' : 'Live';
  String get home => bn ? 'প্রচ্ছদ' : 'Home';
  String get all => bn ? 'সব সংবাদ' : 'All';
  String get retry => bn ? 'আবার চেষ্টা করুন' : 'Try Again';
  String get empty => bn ? 'কোনো সংবাদ পাওয়া যায়নি' : 'No articles found';
  String get menu => bn ? 'আরও' : 'More';
  String get edition => bn ? 'বাংলা সংস্করণ' : 'English Edition';
  String get share => bn ? 'শেয়ার' : 'Share';
  String get source => bn ? 'ওয়েবসাইটে পড়ুন' : 'Open original';
  String get videoSetup => bn ? 'ভিডিও চ্যানেলের লিংক এখনও সেট করা হয়নি।' : 'Video channel URL is not configured yet.';
  String get liveSetup => bn ? 'লাইভ স্ট্রিমের লিংক এখনও সেট করা হয়নি।' : 'Live stream URL is not configured yet.';
}
