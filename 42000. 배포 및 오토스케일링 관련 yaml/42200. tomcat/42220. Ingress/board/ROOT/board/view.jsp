<%@ page import="java.sql.*,java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // 세션이 존재하는지 확인
    HttpSession userSession = request.getSession(false);

    // 로그인 여부 확인
    boolean isLoggedIn = (userSession != null && userSession.getAttribute("username") != null);

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    // 게시물 ID를 가져옴
    int postId = Integer.parseInt(request.getParameter("id"));

    // 결과를 담을 변수들
    ResultSet resultSet = null;
    Map<String, Object> post = new HashMap<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        // 게시물 조회 쿼리
        String viewQuery = "SELECT * FROM board WHERE id=?";
        PreparedStatement viewStmt = conn.prepareStatement(viewQuery);
        viewStmt.setInt(1, postId);
        resultSet = viewStmt.executeQuery();

        // 게시물이 존재하는지 확인
        if (resultSet.next()) {
            post.put("id", resultSet.getInt("id"));
            post.put("username", resultSet.getString("username"));
            post.put("title", resultSet.getString("title"));
            post.put("content", resultSet.getString("content"));
            post.put("created_at", resultSet.getTimestamp("created_at"));
        } else {
            // 게시물이 존재하지 않을 경우에 대한 처리
            // 여기에서 필요한 로직을 추가하세요.
        }

        // Close resources
        resultSet.close();
        viewStmt.close();
        conn.close();
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        // Handle exceptions
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판</title>
    <style>
        /* Your existing styling */
        /* Add your CSS styles here */
    </style>
</head>
<body>
    <div id="wrap" class="wrapper">
        <!-- 게시물 표시 코드 -->
        <h1><%= post.get("title") %></h1>
        <p>작성자: <%= post.get("username") %></p>
        <p>작성일시: <%= post.get("created_at") %></p>
        <p><%= post.get("content") %></p>

        <!-- Edit and Delete buttons -->
        <% if (isLoggedIn && userSession.getAttribute("username").equals(post.get("username"))) { %>
            <a href="/edit.jsp?id=<%= post.get("id") %>">Edit</a>
            <a href="/delete.jsp?id=<%= post.get("id") %>">Delete</a>
        <% } %>

        <!-- Your existing comment display code -->
    </div>
</body>
</html>

