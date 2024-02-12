<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="/css/login.css">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <script type="module" src="https://unpkg.com/ionicons@5.5.2/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@5.5.2/dist/ionicons/ionicons.js"></script>
</head>
<body>
    <div class="wrapper">
        <form action="login.jsp" method="post">
            <h2>LOGIN</h2>
            <div class="input-group">
                <span class="icon">
                    <ion-icon name="person"></ion-icon>
                </span>
                <input type="text" placeholder="Username" name="username" required>
            </div>
            <div class="input-group">
                <span class="icon">
                    <ion-icon name="lock-closed"></ion-icon>
                </span>
                <input type="password" placeholder="Password" name="password" required>
            </div>
            <div class="forgot-pass">
                <a href="#">Forgot Password?</a>
            </div>
            <button type="submit" class="btn">Login</button>
            <div class="sign-link">
                <p>Don't have an account? <a href="register.jsp" class="register-link">Register</a></p>
            </div>

            <%
                if (request.getMethod().equalsIgnoreCase("post")) {
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");

                    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
                    String DB_USER = "root";
                    String DB_PASSWORD = "1234";

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                             Statement stmt = conn.createStatement()) {
                            stmt.execute("SET NAMES 'UTF8'");
                            String query = "SELECT * FROM user_info WHERE username=? AND password=?";
                            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                                pstmt.setString(1, username);
                                pstmt.setString(2, password);
                                try (ResultSet rs = pstmt.executeQuery()) {
                                    if (rs.next()) {
                                        // 로그인 성공
                                        HttpSession existingSession = request.getSession(false);
                                        if (existingSession != null) {
                                            existingSession.invalidate();
                                        }
                                        HttpSession newSession = request.getSession(true);
                                        newSession.setAttribute("username", username);
                            %>
                            <script>
                                window.location.href = "/";
                            </script>
                            <%
                                    } else {
                                        // 로그인 실패
                            %>
                            <script>
                                alert("ID or Password incorrect");
                            </script>
                            <%
                                    }
                                }
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<div class='error-message'>An error occurred: " + e.getMessage() + "</div>");
                    } catch (Exception e) {
                        out.println("<div class='error-message'>An unexpected error occurred: " + e.getMessage() + "</div>");
                    }
                }
            %>
        </form>
    </div>
</body>
</html>
