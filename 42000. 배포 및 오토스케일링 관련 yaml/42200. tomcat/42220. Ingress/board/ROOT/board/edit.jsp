<%@ page import="java.sql.*,java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<%! // 클래스 레벨에서 변수 선언
    String title = "";
    String content = "";
    String author = ""; // 작성자 정보 추가
%>

<%
    request.setCharacterEncoding("UTF-8");

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    // 현재 로그인한 사용자 아이디 가져오기 (세션에 저장된 경우)
    String loggedInUser = (String) session.getAttribute("username");

    // 수정할 게시글의 정보를 DB에서 가져오는 코드
    int postId = 0;
    try {
        String postIdParam = request.getParameter("id");
        if (postIdParam != null && !postIdParam.isEmpty()) {
            postId = Integer.parseInt(postIdParam);
        }
    } catch (NumberFormatException e) {
        e.printStackTrace();
        // Handle the exception or redirect with an error message
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet resultSet = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        // 게시글 정보 조회 쿼리
        String postQuery = "SELECT * FROM board WHERE id=?";
        stmt = conn.prepareStatement(postQuery);
        stmt.setInt(1, postId);
        resultSet = stmt.executeQuery();

        if (resultSet.next()) {
            // 게시글 정보를 사용하여 필요한 처리 수행
            // 예: 입력 폼에 기본값으로 설정할 내용 가져오기
            title = resultSet.getString("title");
            content = resultSet.getString("content");
            author = resultSet.getString("username"); // 작성자 정보 가져오기
        } else {
            // 해당 ID의 게시글이 존재하지 않음. 처리 로직 추가
            // 예: 에러 메시지 출력 또는 리다이렉트
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        // Handle exceptions
    } finally {
        // Close resources in finally block
        try {
            if (resultSet != null) resultSet.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Edit Post</title>
    <!-- 필요한 스타일이나 스크립트 등을 추가하세요 -->
    <script>
        // JavaScript 코드를 사용하여 팝업 메시지 표시
        <% String errorMessage = "다른 사람의 게시글을 수정할 수 없습니다.";
           if (loggedInUser != null && loggedInUser.equals(author)) { %>
            // 작성자와 로그인한 사용자가 일치하는 경우에만 수정 폼을 표시
           <% } else { %>
            alert("<%= errorMessage %>");
            // 다른사람의 게시글을 수정할 수 없다는 메시지를 표시하고 게시판 페이지로 리다이렉트
            window.location.href = "board.jsp";
           <% } %>
    </script>
</head>
<body>
    <h2>Edit Post</h2>

    <%-- 작성자와 로그인한 사용자가 일치하는 경우에만 수정 폼을 표시 --%>
    <% if (loggedInUser != null && loggedInUser.equals(author)) { %>
        <!-- 수정 완료 메시지 표시 -->
        <% String updateMessage = (String)request.getAttribute("updateMessage");
            if (updateMessage != null && !updateMessage.isEmpty()) { %>
            <p><%= updateMessage %></p>
        <% } %>

        <!-- 수정 폼 작성 -->
        <!-- 예: <form action="/update.jsp" method="post"> -->
        <form action="update.jsp" method="post">
            <!-- hidden 필드로 게시글 ID 전달 -->
            <input type="hidden" name="id" value="<%= postId %>">
            <label for="title">Title:</label>
            <input type="text" id="title" name="title" value="<%= title %>">
            <br>
            <label for="content">Content:</label>
            <textarea id="content" name="content"><%= content %></textarea>
            <br>
            <input type="submit" value="Update">
        </form>
    <% } else { %>
        <p>You do not have permission to edit this post.</p>
    <% } %>
</body>
</html>
