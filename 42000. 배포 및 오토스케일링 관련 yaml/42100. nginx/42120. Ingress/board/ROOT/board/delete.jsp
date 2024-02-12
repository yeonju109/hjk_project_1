<%@ page import="java.sql.*,java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    // 데이터베이스 연결 정보
    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    // 현재 로그인한 사용자 아이디 가져오기 (세션에 저장된 경우)
    String loggedInUser = (String) session.getAttribute("username");

    // 삭제할 게시글의 정보를 DB에서 가져오는 코드
    int postId = 0;
    boolean hasPermissionToDelete = false;

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet resultSet = null;

    try {
        String postIdParam = request.getParameter("id");
        if (postIdParam != null && !postIdParam.isEmpty()) {
            postId = Integer.parseInt(postIdParam);
        }

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
                // 예: 삭제 폼에 기본값으로 설정할 내용 가져오기
                String author = resultSet.getString("username"); // 작성자 정보 가져오기

                // Check if the logged-in user has permission to delete the post
                hasPermissionToDelete = loggedInUser != null && loggedInUser.equals(author);
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
    } catch (NumberFormatException e) {
        e.printStackTrace();
        // Handle the exception or redirect with an error message
    }

    // 게시글 삭제 로직
    if (request.getParameter("confirmed") != null && request.getParameter("confirmed").equals("true")) {
        if (hasPermissionToDelete) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                // 게시글 삭제 쿼리
                String deleteQuery = "DELETE FROM board WHERE id=?";
                stmt = conn.prepareStatement(deleteQuery);
                stmt.setInt(1, postId);
                stmt.executeUpdate();
                // 게시글이 삭제되었다는 메시지를 세션에 저장
                request.getSession().setAttribute("deleteMessage", "게시글이 삭제되었습니다.");
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
        } else {
            // 다른 사람의 게시글을 삭제할 수 없다는 메시지를 세션에 저장
            request.getSession().setAttribute("deleteMessage", "다른 사람의 게시글을 삭제할 수 없습니다.");
        }
        // 게시글이 삭제되었으므로 게시판 페이지로 리다이렉트
        response.sendRedirect("board.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Delete Post</title>
    <!-- 필요한 스타일이나 스크립트 등을 추가하세요 -->
    <script>
        function confirmDelete() {
            var result = confirm("정말로 삭제하시겠습니까?");
            if (result) {
                // "확인"을 클릭한 경우
                // 여기에 게시글을 삭제하는 코드 추가
                <% if (hasPermissionToDelete) { %>
                    window.location.href = "delete.jsp?id=<%=postId%>&confirmed=true";
                <% } else { %>
                    alert("다른 사람의 게시글을 삭제할 수 없습니다.");
                    window.location.href = "board.jsp";
                <% } %>
            } else {
                // "취소"를 클릭한 경우
                // 게시판 목록으로 돌아가기
                alert("게시글 삭제가 취소되었습니다.");
                window.location.href = "board.jsp";
            }
        }

        // 페이지 로드 시 자동으로 팝업창 띄우기
        window.onload = function() {
            confirmDelete();
        };
    </script>
</head>
<body>
    <%-- 작성자와 로그인한 사용자가 일치하는 경우에만 삭제 폼을 표시 --%>
    <% if (hasPermissionToDelete) { %>
        <!-- 삭제 완료 메시지 표시 -->
        <% String deleteMessage = (String)request.getSession().getAttribute("deleteMessage");
           if (deleteMessage != null && !deleteMessage.isEmpty()) { %>
            <script>
                alert("<%= deleteMessage %>");
            </script>
        <% } %>
    <% } else { %>
        <script>
            // 다른 사람의 게시글을 삭제할 수 없다는 메시지를 표시하고 게시판 페이지로 리다이렉트
            alert("다른 사람의 게시글을 삭제할 수 없습니다.");
            window.location.href = "board.jsp";
        </script>
    <% } %>
</body>
</html>
