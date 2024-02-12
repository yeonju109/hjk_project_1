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
    <link rel="stylesheet" type="text/css" href="/css/register.css">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
</head>
<body>
<div id="wrap" class="wrapper">
    <form action="register.jsp" method="post" name="join" id="join" accept-charset="UTF-8">
        <header>
            <div id="header">
                <h2 class="h_loho">
                    <p>REGISTER</p>
                </h2>
            </div>
        </header>

        <div id="container">
            <div class="row_group">
                <input type="text" placeholder="ID" name="username" required>
                <div class="userInput"></div>
            </div>
        </div>

        <div id="container">
            <div class="row_group">
                <input type="password" placeholder="PASSWORD" name="password" required>
                <div class="userInput"></div>
            </div>
        </div>

        <div id="container">
            <div class="row_group">
                <input type="password" placeholder="PASSWORD CHECK" name="password_check" required>
                <div class="userInput"></div>
            </div>
        </div>

        <div id="container">
            <div class="row_group">
                <input type="text" placeholder="NAME" name="name" required>
                <div class="userInput"></div>
            </div>
        </div>

        <div id="container">
            <div class="row_group">
                <input type="text" placeholder="E-MAIL ADDRESS" name="email" required>
                <div class="userInput"></div>
            </div>
        </div>

        <div id="container">
            <div class="row_group">
                <input type="text" placeholder="PHONE NUMBER" name="phone_number" required>
                <div class="userInput"></div>
            </div>
        </div>

        <button type="submit" class="btn">REGISTER</button>
    </form>

    <div id="message-container">
        <%
            if (request.getMethod().equalsIgnoreCase("post")) {
                String username = request.getParameter("username");
                System.out.println("Received username: " + username);
                String password = request.getParameter("password");
                String password_check = request.getParameter("password_check");
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone_number = request.getParameter("phone_number");

                if (username != null && password != null && password_check != null && name != null && email != null && phone_number != null) {
                    if (password.equals(password_check)) {
                        String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
                        String DB_USER = "root";
                        String DB_PASSWORD = "1234";

                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                            Statement stmt = conn.createStatement();
                            stmt.execute("SET NAMES 'UTF8'");
                            String checkQuery = "SELECT * FROM user_info WHERE username=?";
                            PreparedStatement checkStmt = conn.prepareStatement(checkQuery);
                            checkStmt.setString(1, username);
                            ResultSet rs = checkStmt.executeQuery();

                            if (!rs.next()) {
                                String insertQuery = "INSERT INTO user_info (username, password, name, email, phone_number) VALUES (?, ?, ?, ?, ?)";
                                PreparedStatement pstmt = conn.prepareStatement(insertQuery);
                                pstmt.setString(1, username);
                                pstmt.setString(2, password);
                                pstmt.setString(3, name);
                                pstmt.setString(4, email);
                                pstmt.setString(5, phone_number);
                                pstmt.executeUpdate();

                                // Create a new session
                                HttpSession newSession = request.getSession(true);

                                // Store the username in the session
                                newSession.setAttribute("username", username);

                                out.println("<div class='success-message'>Registration successful!</div>");
        %>
                                <!-- Redirect the user to the home page after successful registration -->
                                <script>
                                    alert("회원가입이 완료되었습니다!");
                                    window.location.href = "/";
                                </script>
        <%
                            } else {
                                // Existing username error message
                                out.println("<div class='error-message'>동일한 ID가 존재합니다</div>");
                            }

                        } catch (SQLException e) {
                            out.println("<div class='error-message'>An error occurred: " + e.getMessage() + "</div>");
                        } catch (Exception e) {
                            out.println("<div class='error-message'>An unexpected error occurred: " + e.getMessage() + "</div>");
                        }
                    } else {
                        // Password mismatch error message
                        out.println("<div class='error-message'>비밀번호가 일치하지 않습니다</div>");
                    }
                } else {
                    // Null input fields error message
                    out.println("<div class='error-message'>An error occurred: One or more input fields are null</div>");
                }
            }
        %>
    </div>
</div>
</body>
</html>
