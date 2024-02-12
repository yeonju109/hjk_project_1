<%@ page import="java.sql.*" %>
<%@ page import="java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
  // 세션이 존재하는지 확인
  HttpSession userSession = request.getSession(false);

  // 로그인 여부 확인
  boolean isLoggedIn = (userSession != null && userSession.getAttribute("username") != null);

  // 게시글 작성은 로그인한 사용자에게만 허용
  if (!isLoggedIn) {
    response.sendRedirect("/login.jsp");
  }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>글 작성</title>
</head>
<body>
  <div id="wrap" class="wrapper">
    <form action="/write.jsp" method="post">
      <label for="title">제목:</label>
      <input type="text" id="title" name="title" required>

      <label for="content">내용:</label>
      <textarea id="content" name="content" required></textarea>

      <button type="submit">글 작성</button>
    </form>
  </div>
</body>
</html>

<%
  if (request.getMethod().equalsIgnoreCase("post")) {
    // 게시글 작성 처리 부분
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String username = (String) userSession.getAttribute("username");

    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

      String insertQuery = "INSERT INTO board (username, title, content) VALUES (?, ?, ?)";
      try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
        insertStmt.setString(1, username);
        insertStmt.setString(2, title);
        insertStmt.setString(3, content);
        insertStmt.executeUpdate();
      }
    } catch (SQLException | ClassNotFoundException e) {
      e.printStackTrace();
    }

    response.sendRedirect("/board.jsp");
  }
%>

