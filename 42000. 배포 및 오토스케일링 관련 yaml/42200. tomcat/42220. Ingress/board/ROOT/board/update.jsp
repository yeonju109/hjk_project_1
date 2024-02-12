<%@ page import="java.sql.*,java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    Connection conn = null;
    PreparedStatement stmt = null;
    int rowsAffected = 0; // Declare rowsAffected variable

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        // 수정할 게시글의 정보를 받아옴
        int postId = Integer.parseInt(request.getParameter("id"));
        String newTitle = request.getParameter("title");
        String newContent = request.getParameter("content");

        // 게시글 업데이트 쿼리
        String updateQuery = "UPDATE board SET title=?, content=? WHERE id=?";
        stmt = conn.prepareStatement(updateQuery);
        stmt.setString(1, newTitle);
        stmt.setString(2, newContent);
        stmt.setInt(3, postId);
        rowsAffected = stmt.executeUpdate();

        if (rowsAffected > 0) {
            // 게시글이 성공적으로 업데이트됨
            String updateMessage = "게시글이 성공적으로 수정되었습니다.";
            request.setAttribute("updateMessage", updateMessage);
        } else {
            // 게시글 업데이트 실패
            String errorMessage = "게시글 업데이트에 실패했습니다.";
            request.setAttribute("errorMessage", errorMessage);
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        // Handle exceptions
    } finally {
        // Close resources in finally block
        try {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 수정이 완료되면 게시판 목록 페이지로 리다이렉트
    response.sendRedirect("board.jsp");
%>
