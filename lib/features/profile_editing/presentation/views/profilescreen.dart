// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/jupiter_cubit.dart';
import '../../../../core/utils/variables.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../../../login/logic/models/user_model.dart';
import '../../logic/image_change_builder.dart';
import '../../../../core/widgets/my_list_tile.dart';
import '../../logic/password_editing_screen.dart';
import '../../logic/payment_editing_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    print(widget.userModel.phone);
    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Center(
          child: ListView(
            children: [
              SizedBox(
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BlocBuilder<JupiterCubit, JupiterState>(
                        builder: (context, state) {
                          String imageUrl;
                          if (state is ImageChangedState &&
                              state.imageUrl != null) {
                            imageUrl = state.imageUrl!;
                          } else {
                            imageUrl = widget.userModel.profileImagePath !=
                                        '' &&
                                    widget.userModel.profileImagePath != ''
                                ? widget.userModel.profileImagePath
                                : 'https://jupiter-academy.org/assets/images/Jupiter%20Outlined.png';
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10000),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: screenWidth * 0.6,
                              width: screenWidth * 0.6,
                            ),
                          );
                        },
                      ),
                      widget.userModel.id == thisUserId
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ImageChangeBuilder(
                                          userModel: widget.userModel,
                                        ),
                                      ),
                                    );
                                    BlocProvider.of<JupiterCubit>(context)
                                        .changeImage(widget.userModel.id);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              MyListTile(
                title: 'Name: ${widget.userModel.name}',
              ),
              MyListTile(
                title: 'Role: ${widget.userModel.role}',
              ),
              MyListTile(
                title: 'Branch: ${widget.userModel.branch}',
              ),
              widget.userModel.id == thisUserId
                  ? MyListTile(
                      title: 'Password: **************',
                      canEdit: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordEditingScreen(
                              userModel: widget.userModel,
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox(),
              MyListTile(
                title: 'phone: ${widget.userModel.whatsApp}',
              ),
              MyListTile(
                title:
                    'Instapay username / Card number: ${widget.userModel.instapayLink}',
                canEdit: widget.userModel.id == thisUserId,
                iconType: widget.userModel.id == thisUserId ? 'edit' : 'copy',
                onTap: () {
                  if (widget.userModel.id == thisUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentEditingScreen(userModel: widget.userModel),
                      ),
                    );
                  } else {
                    Clipboard.setData(
                        ClipboardData(text: widget.userModel.paymentInfo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard'),
                      ),
                    );
                  }
                },
              ),
              MyListTile(
                title: 'Cash wallet: ${widget.userModel.cashWallet}',
                canEdit: widget.userModel.id == thisUserId,
                iconType: widget.userModel.id == thisUserId ? 'edit' : 'copy',
                onTap: () {
                  if (widget.userModel.id == thisUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentEditingScreen(userModel: widget.userModel),
                      ),
                    );
                  } else {
                    Clipboard.setData(
                        ClipboardData(text: widget.userModel.paymentInfo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard'),
                      ),
                    );
                  }
                },
              ),
              MyListTile(
                title: 'Card holder number: ${widget.userModel.cardHolderName}',
                canEdit: widget.userModel.id == thisUserId,
                iconType: widget.userModel.id == thisUserId ? 'edit' : 'copy',
                onTap: () {
                  if (widget.userModel.id == thisUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentEditingScreen(userModel: widget.userModel),
                      ),
                    );
                  } else {
                    Clipboard.setData(
                        ClipboardData(text: widget.userModel.paymentInfo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard'),
                      ),
                    );
                  }
                },
              ),
              MyListTile(
                title: 'StartedAt: ${widget.userModel.getStartedAt}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  /*onTap: () async {
                  // النص الذي يحتوي على معلومات الدفع
                  String paymentInfo = widget.userModel.paymentInfo;

                  // تعبير منتظم لاستخراج الاسم بعد 'Card/VFCash:'
                  RegExp regex =
                      RegExp(r'Card/VFCash:\s*(\w+)', caseSensitive: false);
                  Match? match = regex.firstMatch(paymentInfo);

                  if (match != null) {
                    // استخراج الاسم من التعبير المنتظم
                    String userName = match.group(1) ?? '';

                    // بناء الرابط باستخدام الاسم المستخرج
                    String url = 'https://ipn.eg/S/$userName/instapay/4ckVQX';
                    Uri uri = Uri.parse(url);

                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        print('Could not launch $url');
                      }
                    } catch (e) {
                      print('Error launching URL: $e');
                    }
                  } else {
                    print('Username not found in payment info');
                  }
                },*/
                    