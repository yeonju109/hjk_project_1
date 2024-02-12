<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.*" %>

<%
  // Invalidate the session to log out the user
  HttpSession existingSession = request.getSession(false);
  if (existingSession != null) {
    existingSession.invalidate();
  }
  
  // Redirect to the desired URL (changed to "/")
  response.sendRedirect("/");
%>

