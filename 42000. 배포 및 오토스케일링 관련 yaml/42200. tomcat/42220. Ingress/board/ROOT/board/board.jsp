<%@ page import="java.sql.*,java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*" %>
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String DB_URL = "jdbc:mysql://10.100.0.113:3306/car?useUnicode=true&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASSWORD = "1234";

    ResultSet resultSet = null;
    int totalPages = 0;

    HttpSession userSession = request.getSession(false);
    boolean isLoggedIn = (userSession != null && userSession.getAttribute("username") != null);
    String loggedInUsername = (String) userSession.getAttribute("username");

    // Logging for session information
    System.out.println("User session: " + userSession);
    System.out.println("Is logged in: " + isLoggedIn);
    System.out.println("Logged in username: " + loggedInUsername);

    List<Map<String, Object>> posts = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        int currentPage = 1;
        if (request.getParameter("page") != null) {
            currentPage = Integer.parseInt(request.getParameter("page"));
        }

        int pageSize = 20;
        int start = (currentPage - 1) * pageSize;

        String listQuery = "SELECT * FROM board ORDER BY created_at DESC LIMIT ?, ?";
        PreparedStatement listStmt = conn.prepareStatement(listQuery);
        listStmt.setInt(1, start);
        listStmt.setInt(2, pageSize);
        resultSet = listStmt.executeQuery();

        String countQuery = "SELECT COUNT(*) AS count FROM board";
        Statement countStmt = conn.createStatement();
        ResultSet countResult = countStmt.executeQuery(countQuery);
        countResult.next();
        int totalCount = countResult.getInt("count");

        totalPages = (int) Math.ceil((double) totalCount / pageSize);

        // Search functionality
        String searchType = request.getParameter("searchType");
        String keyword = request.getParameter("keyword");

        if (searchType != null && keyword != null) {
            try {
                String searchQuery = "SELECT * FROM board WHERE ";
                switch (searchType) {
                    case "title":
                        searchQuery += "title LIKE ?";
                        break;
                    case "title_content":
                        searchQuery += "title LIKE ? OR content LIKE ?";
                        break;
                    case "content":
                        searchQuery += "content LIKE ?";
                        break;
                    case "username":
                        searchQuery += "username LIKE ?";
                        break;
                    default:
                        break;
                }

                searchQuery += " ORDER BY created_at DESC LIMIT ?, ?";

                PreparedStatement searchStmt = conn.prepareStatement(searchQuery);
                searchStmt.setString(1, "%" + keyword + "%");
                if (searchType.equals("title_content")) {
                    searchStmt.setString(2, "%" + keyword + "%");
                    searchStmt.setInt(3, start);
                    searchStmt.setInt(4, pageSize);
                } else {
                    searchStmt.setInt(2, start);
                    searchStmt.setInt(3, pageSize);
                }

                resultSet = searchStmt.executeQuery();

                while (resultSet.next()) {
                    Map<String, Object> post = new HashMap<>();
                    post.put("id", resultSet.getInt("id"));
                    post.put("username", resultSet.getString("username"));
                    post.put("title", resultSet.getString("title"));
                    post.put("content", resultSet.getString("content"));
                    post.put("created_at", resultSet.getTimestamp("created_at"));
                    posts.add(post);
                }

                resultSet.close();
                searchStmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
                // Logging for any exceptions during search
                System.out.println("Exception during search: " + e.getMessage());
            }
        }
        // End of search functionality

        // Logging for successful retrieval of posts
        System.out.println("Successfully retrieved posts");

        while (resultSet.next()) {
            Map<String, Object> post = new HashMap<>();
            post.put("id", resultSet.getInt("id"));
            post.put("username", resultSet.getString("username"));
            post.put("title", resultSet.getString("title"));
            post.put("content", resultSet.getString("content"));
            post.put("created_at", resultSet.getTimestamp("created_at"));
            posts.add(post);
        }

        resultSet.close();
        listStmt.close();
        countStmt.close();
        conn.close();

        request.setAttribute("posts", posts);
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        // Logging for any exceptions during database operations
        System.out.println("Exception during database operations: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="/css/board.css">
    <title>게시판</title>
    <script>
      window.onload = function() {
        var httpRequest = new XMLHttpRequest();
        httpRequest.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
            var response = JSON.parse(this.responseText);
            if (response.loggedIn) {
              document.getElementById('navbar').innerHTML = '<li><a href="/">HOME</a></li><li><a href="/login/logout.jsp">LOGOUT</a></li>';
            } else {
              document.getElementById('navbar').innerHTML = '<li><a href="/">HOME</a></li><li><a href="/login">LOGIN</a></li>';
            }
          }
        };
        httpRequest.open("GET", "/login/checkLoginStatus.jsp", true);
        httpRequest.send();
      };
    </script>
</head>
<body>
    <div class="intro_bg">
        <div class="header">
          <div class="searchArea">
            <form>
              <input type="search" placeholder="search">
              <span>검색</span>
            </form>
          </div>
          <ul class="nav" id="navbar">
            <!-- 로그인 상태에 따라 링크가 여기에 삽입됩니다. -->
          </ul>
        </div>
      </div>
    <div id="wrap1" class="wrapper1">
        <table>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Title</th>
                <th>Created At</th>
            </tr>
            <%
                for (Map<String, Object> row : posts) {
            %>
                <tr>
                    <td><%= row.get("id") %></td>
                    <td><%= row.get("username") %></td>
                    <td>
                        <a href="/view.jsp?id=<%= row.get("id") %>"><%= row.get("title") %></a>
                    </td>
                    <td><%= row.get("created_at") %></td>
                </tr>
            <%
                }
            %>
        </table>

        <div class="write">
        <% if (isLoggedIn) { %>
            <a href="/write.jsp">글쓰기</a>
        <% } %>

        <%
            for (int i = 1; i <= totalPages; i++) {
        %>
            <a href="/board.jsp?page=<%= i %>"><%= i %></a>
        <%
            }
        %>

        <form action="/board.jsp" method="get">
            <select name="searchType">
                <option value="title">제목</option>
                <option value="title_content">제목+내용</option>
                <option value="content">내용</option>
                <option value="username">사용자ID</option>
            </select>
            <input type="text" name="keyword" required>
            <button type="submit">검색</button>
        </form>
    </div>
    </div>
    <div class="main_text2">
        <ul>
          <li>
            <div><h1>CONTACT</h1></div>
            <div>우리에게 파트너십을 신청하거나, 고객이 되어주세요</div>
            <div class="more2">더 알아보기</div>
          </li>
          <li></li>
        </ul>
      </div>
      <div class="footer">
        <div>LOGO</div>
        <div>
          CEO. 정석쌤과 아이들 <br>
          Addr. 당신이 있는 곳 어디든<br>
        </div>
      </div>
    </div>
</body>
</html>
