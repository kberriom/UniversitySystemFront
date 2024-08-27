import 'package:university_system_front/Model/page_info.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';

abstract interface class SubjectRepository {
  Future<TeacherAssignation> addTeacher(int teacherId, String subjectName, String roleInClass);

  Future<TeacherAssignation> modifyTeacherRole(int teacherId, String subjectName, String roleInClass);

  Future<Subject> createSubject(SubjectDto subjectDto);

  Future<StudentSubjectRegistration> addStudent(int studentId, int subjectName);

  ///URL param [subjectDto.name]
  Future<Subject> updateSubject(SubjectDto subjectDto);

  Future<Subject> getSubject(String name);

  ///URL param [subjectName]
  Future<List<TeacherAssignation>> getAllTeachers();

  Future<List<Subject>> getAllSubjects();

  Future<PaginatedList<Subject>> getAllSubjectsPaged(int page, int size);

  ///URL param [subjectName]
  Future<List<StudentSubjectRegistration>> getAllRegisteredStudents();

  Future<void> removeTeacher(int teacherId, String subjectName);

  Future<void> removeStudent(int studentId, String subjectName);

  Future<void> deleteSubject(String subjectName);
}
