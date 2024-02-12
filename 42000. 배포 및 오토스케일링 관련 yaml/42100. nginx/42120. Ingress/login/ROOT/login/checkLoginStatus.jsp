<%
String username = (String) session.getAttribute("username");
String json;
if (username != null) {
    // 로그인 상태인 경우
    json = "{\"loggedIn\": true}";
} else {
    // 로그인 상태가 아닌 경우
    json = "{\"loggedIn\": false}";
}
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(json);
%>
