enum UserRole {
  guest,
  participant,
  teamLead,
  head;

  String get label => switch (this) {
        UserRole.guest => 'Guest',
        UserRole.participant => 'Participant',
        UserRole.teamLead => 'Team Lead',
        UserRole.head => 'Head',
      };

  static UserRole fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'participant' => UserRole.participant,
      'team_lead' || 'teamlead' || 'team lead' => UserRole.teamLead,
      'head' => UserRole.head,
      _ => UserRole.guest,
    };
  }
}
