class UserProfile {
  final String? bannerImageUrl;
  final String? profileImageUrl;
  final String? handleName;
  final String? name;
  final String? bioInfo;
  final DateTime? dateOfBirth;
  final String? userOrganization;
  final String? organizationSymbol;
  final String? organizationAbbreviation;
  final String? currentPosition;
  final String? localDivisionName;
  final String? regionalDivisionName;
  final String? nationalDivisionName;

  UserProfile({
    this.bannerImageUrl,
    this.profileImageUrl,
    this.handleName,
    this.name,
    this.bioInfo,
    this.dateOfBirth,
    this.userOrganization,
    this.organizationSymbol,
    this.organizationAbbreviation,
    this.currentPosition,
    this.localDivisionName,
    this.regionalDivisionName,
    this.nationalDivisionName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bannerImageUrl: json['banner_image_url'],
      profileImageUrl: json['profile_image_url'],
      handleName: json['handle_name'],
      name: json['name'],
      bioInfo: json['bio_info'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      userOrganization: json['user_organization'],
      organizationSymbol: json['organization_symbol'],
      organizationAbbreviation: json['organization_abbreviation'],
      currentPosition: json['current_position'],
      localDivisionName: json['local_division_name'],
      regionalDivisionName: json['regional_division_name'],
      nationalDivisionName: json['national_division_name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'banner_image_url': bannerImageUrl,
      'profile_image_url': profileImageUrl,
      'handle_name': handleName,
      'name': name,
      'bio_info': bioInfo,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'user_organization': userOrganization,
      'organization_symbol': organizationSymbol,
      'organization_abbreviation': organizationAbbreviation,
      'current_position': currentPosition,
      'local_division_name': localDivisionName,
      'regional_division_name': regionalDivisionName,
      'national_division_name': nationalDivisionName,
    };
  }
}
