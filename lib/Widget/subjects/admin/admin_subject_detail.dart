import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Repository/subject/subject_repository.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/animated_text_title.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/scaffold_background_decoration.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AdminSubjectDetailWidget extends ConsumerStatefulWidget {
  final Subject subject;

  const AdminSubjectDetailWidget({super.key, required this.subject});

  @override
  ConsumerState<AdminSubjectDetailWidget> createState() => _SubjectDetailWidgetState();
}

class _SubjectDetailWidgetState extends ConsumerState<AdminSubjectDetailWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              GoRouter.of(context).pushReplacement(
                  '${GoRouterRoutes.adminSubjects.routeName}/${GoRouterRoutes.adminSubjectDetail.routeName}/${GoRouterRoutes.adminEditSubject.routeName}',
                  extra: widget.subject);
            },
            child: const Icon(Icons.mode_edit)),
        body: ScaffoldBackgroundDecoration(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000, minWidth: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AnimatedComboTextTitle(
                          widthFactor: 0.9,
                          upText: context.localizations.subjectItemName,
                          downText: widget.subject.name,
                          downWidget: SubjectLocationsIndicator(subject: widget.subject),
                          underlineWidget: SubjectUnderlineInfo(subject: widget.subject),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ExpansionTile(
                          collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          collapsedShape: const RoundedRectangleBorder(),
                          shape: const RoundedRectangleBorder(),
                          title: Text(context.localizations.subjectDetailSeeMoreInfo),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          children: <Widget>[
                            ListTile(
                                title: Text(
                                    "${context.localizations.adminAddSubjectFormItemCreditsValue}: ${widget.subject.creditsValue}")),
                            ListTile(
                                title: Text(
                                    "${context.localizations.adminAddSubjectFormItemDescription}: ${widget.subject.description}")),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActAddTeacher,
                              icon: const Icon(Icons.add),
                              onPressed: () {}, //todo add action
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActRemoveTeacher,
                              icon: const Icon(Icons.remove),
                              onPressed: () {}, //todo add action
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActAddStudent,
                              icon: const Icon(Icons.add),
                              onPressed: () {}, //todo add action
                            ),
                            QuickActionButton(
                              text: context.localizations.adminSubjectDetailQuickActRemoveStudent,
                              icon: const Icon(Icons.remove),
                              onPressed: () {}, //todo add action
                            ),
                          ],
                        ),
                        AnimatedTextTitle(text: context.localizations.userTypeNameTeacher(2)),
                        SubjectUserCarousel<TeacherAssignation>(
                          future: ref.watch(subjectRepositoryProvider).getAllTeachers(widget.subject.name),
                          subject: widget.subject,
                          userRole: UserRole.teacher,
                        ),
                        AnimatedTextTitle(text: context.localizations.userTypeNameStudent(2)),
                        SubjectUserCarousel<StudentSubjectRegistration>(
                          future: ref.watch(subjectRepositoryProvider).getAllRegisteredStudents(widget.subject.name),
                          subject: widget.subject,
                          userRole: UserRole.student,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectUserCarousel<T> extends ConsumerStatefulWidget {
  const SubjectUserCarousel({
    super.key,
    required this.userRole,
    required this.subject,
    required this.future,
  });

  final Subject subject;
  final UserRole userRole;
  final Future<List<T>> future;

  @override
  ConsumerState<SubjectUserCarousel> createState() => _SubjectUserCarouselState();
}

class _SubjectUserCarouselState extends ConsumerState<SubjectUserCarousel> {
  String noAssignedMsg = "";

  @override
  void didChangeDependencies() {
    noAssignedMsg = switch (widget.userRole) {
      UserRole.admin => throw UnimplementedError(),
      UserRole.teacher => context.localizations.subjectNoTeacherAsgmt,
      UserRole.student => context.localizations.subjectNoStudentAsgmt,
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
          case ConnectionState.active:
            return const SmallCarousel(isPlaceholder: true);
          case ConnectionState.done:
            if (snapshot.data?.isEmpty ?? true) {
              return Align(alignment: Alignment.centerLeft, child: Text(noAssignedMsg));
            }
            //On valid data
            return FutureBuilder(future: Future(
              () {
                return List<Widget>.generate(growable: false, snapshot.data!.length, (index) {
                  //todo: replace with profile picture
                  var data = switch (widget.userRole) {
                    UserRole.admin => throw UnimplementedError(),
                    UserRole.teacher => (snapshot.data![index] as TeacherAssignation).id.teacherUserId.toString(),
                    UserRole.student => (snapshot.data![index] as StudentSubjectRegistration).id.studentUserId.toString(),
                  };
                  return Center(child: Text(data));
                });
              },
            ), builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SmallCarousel(
                  list: snapshot.data!,
                  onTapCallBack: (index) {},
                );
              }
              return const SmallCarousel(isPlaceholder: true);
            });
        }
      },
    );
  }
}

class SmallCarousel extends StatefulWidget {
  final List<Widget> list;
  final void Function(int index)? onTapCallBack;
  final bool isPlaceholder;
  final int placeholderAmount;

  const SmallCarousel(
      {super.key, this.list = const <Widget>[], this.onTapCallBack, this.isPlaceholder = false, this.placeholderAmount = 5});

  @override
  State<SmallCarousel> createState() => _SmallCarouselState();
}

class _SmallCarouselState extends State<SmallCarousel> with AnimationMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = createController(unbounded: true, fps: 60);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ScrollConfiguration(
        behavior: AllDeviceScrollBehavior(),
        child: CarouselView(
          itemExtent: 100,
          itemSnapping: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusBig)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          onTap: widget.onTapCallBack,
          children: widget.isPlaceholder
              ? List.generate(
                  growable: false,
                  widget.placeholderAmount,
                  (index) => SizedBox.expand(
                        child: LoadingShimmerItem(
                          borderRadius: 0,
                          padding: EdgeInsets.zero,
                          itemConstraints: FixedExtentItemConstraints(
                              cardHeight: 100,
                              cardMinWidthConstraints: double.infinity,
                              cardMaxWidthConstraints: double.infinity,
                              animationController: _animationController),
                        ),
                      ))
              : widget.list,
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  final String text;
  final Icon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: icon,
      label: Text(text),
      style: ButtonStyle(
          fixedSize: const WidgetStatePropertyAll(Size.fromHeight(60)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall))),
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainer)),
    );
  }
}

class AllDeviceScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class SubjectLocationsIndicator extends StatelessWidget {
  final Subject subject;

  const SubjectLocationsIndicator({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        if (subject.remote) Tooltip(message: context.localizations.subjectItemIsRemote, child: const Icon(Icons.laptop)),
        if (subject.onSite) Tooltip(message: context.localizations.subjectItemIsOnSite, child: const Icon(Icons.home_work)),
      ],
    );
  }
}

class SubjectUnderlineInfo extends StatelessWidget {
  final Subject subject;

  const SubjectUnderlineInfo({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(message: context.localizations.subjectDetailUnderlineInfoId, child: const Icon(Icons.badge_outlined)),
            const SizedBox(width: 5),
            Text("${subject.id}")
          ],
        ),
        if ((subject.roomLocation ?? "").isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(message: context.localizations.adminAddSubjectFormItemRoomLoc, child: const Icon(Icons.location_on_sharp)),
              const SizedBox(width: 5),
              Text(subject.roomLocation ?? "")
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
                message: context.localizations.subjectDetailUnderlineInfoDate, child: const Icon(Icons.calendar_month_outlined)),
            const SizedBox(width: 5),
            if (DateTime.tryParse(subject.startDate)!.isAfter(DateTime.now()))
              Text("${context.localizations.subjectDetailUnderlineInfoDateStart} ${subject.startDate}"),
            if (DateTime.tryParse(subject.startDate)!.isBefore(DateTime.now()))
              Text("${context.localizations.subjectDetailUnderlineInfoDateEnd} ${subject.endDate}"),
          ],
        ),
      ],
    );
  }
}
