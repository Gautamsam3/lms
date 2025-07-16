class UserData {
  static String userName = 'John Doe';
  static String userEmail = 'john.doe@college.edu';
  static String userCourse = 'Computer Science • Final Year';
  
  static void updateUser({
    required String name,
    required String email,
    String? course,
  }) {
    userName = name;
    userEmail = email;
    if (course != null) {
      userCourse = course;
    }
  }
  
  static void clearUser() {
    userName = 'John Doe';
    userEmail = 'john.doe@college.edu';
    userCourse = 'Computer Science • Final Year';
  }
}