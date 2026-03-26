enum InspectionCategoryKey {
  housekeepingIndoor,
  housekeepingOutdoor,
  maintenance,
  security,
  landscape,
}

class ChecklistSectionData {
  const ChecklistSectionData({
    required this.title,
    required this.category,
    required this.items,
  });

  final String title;
  final InspectionCategoryKey category;
  final List<String> items;
}

abstract final class QualityChecklistItems {
  static const List<String> housekeepingIndoor = [
    'Company staff adhere to uniform, appearance, and proper conduct',
    'Maintenance staff comply with occupational health and safety requirements',
    'Ensure no tools are left after working hours',
    'Proper cleaning of lighting units',
    'No leaks in corridors or buildings',
    'Electrical panels are clean and free of dust',
    'Electrical panels are closed',
    'Administrative corridors are clean',
    'Floor restrooms are clean',
    'Administrative kitchens are clean',
    'Security and gate restrooms are clean',
    'Building entrances are clean',
  ];

  static const List<String> housekeepingOutdoor = [
    'Company staff adhere to uniform, appearance, and proper conduct',
    'Grounds are free of harmful weeds',
    'Irrigation is consistent with no dry patches',
    'Grounds are cleared of debris and leaves',
    'Dead or hanging branches are trimmed',
    'No visible pests or infestations',
    'Plants are free from yellowing or wilting',
    'Plant beds are free of weeds',
    'Ensure water is not sprayed onto sidewalks or buildings',
    'No irrigation leaks; system appearance is proper',
    'Grass height is within the required level',
    'No agricultural waste left after working hours',
  ];

  static const List<String> maintenance = [
    'Company staff adhere to uniform, appearance, and proper conduct',
    'Presence at the assigned location without absence',
    'Adherence to public interaction guidelines',
    'Follow security input when discussing plans',
    'Proper reporting of emergencies and incidents',
    'Reports are submitted on time as per agreement',
    'Safety and security equipment are functional',
    'Checklist is updated during service',
    'Coverage of all critical areas',
    'Do not leave the guard post without a replacement',
    'No mobile phone use during work',
  ];

  static const List<String> security = [
    'Company staff adhere to uniform, appearance, and proper conduct',
    'Security staff maintain clean uniform and personal appearance',
    'Presence at the assigned location without absence',
    'Adherence to public interaction guidelines',
    'Follow security input when discussing plans',
    'Proper reporting of emergencies and incidents',
    'Emergency contact number is operational during service',
    'No security breaches',
    'Electrical panels are closed',
    'Immediate reporting of any observations and required fixes',
    'Directorate evaluations are completed on time as per agreement',
    'Safety and security equipment are functional',
    'Checklist is closed during service',
    'Coverage of all critical areas',
    'Do not leave the guard post without a replacement',
    'No mobile phone use during work',
  ];

  static const List<String> landscape = [
    'Company staff adhere to uniform, appearance, and proper conduct',
    'Grass height is within the required level',
    'No irrigation leaks; system appearance is proper',
    'No agricultural waste left after working hours',
    'Grounds are free of harmful weeds',
    'Irrigation is consistent with no dry patches',
    'Grounds are cleared of debris and leaves',
    'Dead or hanging branches are trimmed',
    'No visible pests or infestations',
    'Plants are free from yellowing or wilting',
    'Plant beds are free of weeds',
    'Ensure water is not sprayed onto sidewalks or buildings',
  ];
}
