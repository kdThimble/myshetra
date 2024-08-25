import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:myshetra/Components/like_animation.dart';
import 'package:myshetra/Models/UserModel.dart';
import 'package:myshetra/Models/post_model.dart';
import 'package:myshetra/Services/user_shared_pref.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post post;
  UserProfile? profile;
  bool isLikeAnimating = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _loadUserProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    UserProfilePreference prefs = UserProfilePreference();
    UserProfile? loadedProfile = await prefs.loadUserProfile();
    setState(() {
      profile = loadedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    DateTime postDate = DateTime.parse(post.createdAt);
    String timeAgo = timeago.format(postDate, locale: 'en_long');
    return Container(
      // boundary needed for web
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: width * 0.09,
                  backgroundImage: const NetworkImage(
                    'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?size=626&ext=jpg&ga=GA1.1.101892706.1718654435&semt=sph',
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          profile?.name ?? "User",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.more_vert_rounded,
                  size: 28,
                ),
                SizedBox(
                  width: width * 0.05,
                )
                // widget.snap['uid'].toString() == user.uid
                //     ? IconButton(
                //         onPressed: () {
                //           showDialog(
                //             useRootNavigator: false,
                //             context: context,
                //             builder: (context) {
                //               return Dialog(
                //                 child: ListView(
                //                     padding: const EdgeInsets.symmetric(
                //                         vertical: 16),
                //                     shrinkWrap: true,
                //                     children: [
                //                       'Delete',
                //                     ]
                //                         .map(
                //                           (e) => InkWell(
                //                               child: Container(
                //                                 padding:
                //                                     const EdgeInsets.symmetric(
                //                                         vertical: 12,
                //                                         horizontal: 16),
                //                                 child: Text(e),
                //                               ),
                //                               onTap: () {
                //                                 deletePost(
                //                                   widget.snap['postId']
                //                                       .toString(),
                //                                 );
                //                                 // remove the dialog box
                //                                 Navigator.of(context).pop();
                //                               }),
                //                         )
                //                         .toList()),
                //               );
                //             },
                //           );
                //         },
                //         icon: const Icon(Icons.more_vert),
                //       )
                //     : Container(),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              // FireStoreMethods().likePost(
              //   widget.snap['postId'].toString(),
              //   user.uid,
              //   widget.snap['likes'],
              // );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: post.media.length,
                    itemBuilder: (context, index) {
                      final mediaItem = post.media[index];
                      return Image.network(
                        mediaItem.filePath,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 15,
                  child: SmoothPageIndicator(
                    controller: _pageController, // PageController
                    count: post.media.length,
                    effect: const WormEffect(
                      dotHeight: 10.0,
                      dotWidth: 10.0,
                      activeDotColor: Colors.white,
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              LikeAnimation(
                isAnimating: false,
                smallLike: true,
                child: IconButton(
                    icon: const Icon(
                      Icons.thumb_up_off_alt_outlined,
                    ),
                    onPressed: () => {}),
              ),
              Text(
                '${post.postInteractions.likes}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                  icon: Image.asset("assets/icons/messages-2.png"),
                  onPressed: () => {}),
              Text(
                '${post.postInteractions.comments}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                  icon: Image.asset("assets/icons/eye.png"), onPressed: () {}),
              Text(
                '${post.postInteractions.views}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: Image.asset("assets/icons/send-2.png"),
                        onPressed: () {}),
                    Text(
                      '${post.postInteractions.shares}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                ),
              ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 17),
                      children: [
                        TextSpan(
                          text: post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${post.subTitle}}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
