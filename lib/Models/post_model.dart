class ApiResponse {
  int page;
  int pageSize;
  int totalPosts;
  List<Post> posts;

  ApiResponse({
    required this.page,
    required this.pageSize,
    required this.totalPosts,
    required this.posts,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      page: json['page'],
      pageSize: json['pageSize'],
      totalPosts: json['totalPosts'],
      posts: List<Post>.from(json['posts'].map((post) => Post.fromJson(post))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'totalPosts': totalPosts,
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }
}

class Post {
  int id;
  String title;
  String subTitle;
  String content;
  String addedBy;
  String updatedBy;
  String createdAt;
  String updatedAt;
  List<dynamic> tagging;
  List<Media> media;
  PostInteractions postInteractions;

  Post({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.content,
    required this.addedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.tagging,
    required this.media,
    required this.postInteractions,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['ID'],
      title: json['Title'],
      subTitle: json['SubTitle'],
      content: json['Content'],
      addedBy: json['AddedBy'],
      updatedBy: json['UpdatedBy'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      tagging: List<dynamic>.from(json['Tagging']),
      media: List<Media>.from(json['Media'].map((m) => Media.fromJson(m))),
      postInteractions: PostInteractions.fromJson(json['PostInteractions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Title': title,
      'SubTitle': subTitle,
      'Content': content,
      'AddedBy': addedBy,
      'UpdatedBy': updatedBy,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
      'Tagging': tagging,
      'Media': media.map((m) => m.toJson()).toList(),
      'PostInteractions': postInteractions.toJson(),
    };
  }
}

class Media {
  int id;
  String filePath;
  String mediaType;
  String createdAt;
  String addedBy;
  String updatedBy;

  Media({
    required this.id,
    required this.filePath,
    required this.mediaType,
    required this.createdAt,
    required this.addedBy,
    required this.updatedBy,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['ID'],
      filePath: json['FilePath'],
      mediaType: json['MediaType'],
      createdAt: json['CreatedAt'],
      addedBy: json['AddedBy'],
      updatedBy: json['UpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'FilePath': filePath,
      'MediaType': mediaType,
      'CreatedAt': createdAt,
      'AddedBy': addedBy,
      'UpdatedBy': updatedBy,
    };
  }
}

class PostInteractions {
  int id;
  int postId;
  int likes;
  int views;
  int comments;
  int shares;
  String createdAt;
  String updatedAt;

  PostInteractions({
    required this.id,
    required this.postId,
    required this.likes,
    required this.views,
    required this.comments,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostInteractions.fromJson(Map<String, dynamic> json) {
    return PostInteractions(
      id: json['ID'],
      postId: json['PostID'],
      likes: json['Likes'],
      views: json['Views'],
      comments: json['Comments'],
      shares: json['Shares'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'PostID': postId,
      'Likes': likes,
      'Views': views,
      'Comments': comments,
      'Shares': shares,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }
}
