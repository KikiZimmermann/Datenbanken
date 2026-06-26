<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.sql.DataSource" %>
<%@page import="java.sql.Connection" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="javax.naming.InitialContext" %>
<%@page import="org.apache.commons.lang3.StringUtils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
  <head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" href="${contextPath}/css/main.css" />
    <title>Weine</title>
  </head>
  <body>
    <h1>Weine</h1>
    <%
      String name = request.getParameter("wName") == null ? "" : request.getParameter("wName");
    %>    
    <form method="GET" action="">
      <p>Suche nach Teil vom Namen: <input name="wName" type="text" value="<%=name%>"/>
        <button class="btn btn-primary">Suchen</button>
      </p>
    </form>
      <a href="<%= request.getContextPath()%>/index.jsp">Zur Startseite</a> - <a href="<%= request.getContextPath()%>/neuer-wein.jsp">Neuen Wein anlegen</a>
        <hr /><br/>
<%
  InitialContext ctx = new InitialContext();
  DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/WeineDB");

  try (Connection con = ds.getConnection()) {
    String sqlStr = "SELECT WeinId, Name, Farbe, Jahrgang FROM WEINE";
    if (StringUtils.isNotBlank(name)) {
      sqlStr += " WHERE name like ?";
    }
    try (PreparedStatement ps = con.prepareStatement(sqlStr)) {
      if (StringUtils.isNotBlank(name)) {
        ps.setString(1, "%" + name + "%");
      }
      ResultSet rs = ps.executeQuery();
      if (!rs.next()) {
      %>
      <p style="color: red;">Keine Einträge gefunden!</p>
      <%
      } else {
      %>
      <table class="data table-striped">
        <tr><th>Name</th><th>Farbe</th><th>Jahrgang</th></tr>
        <% do {%>
      <tr><td><%= rs.getString("Name")%></td><td><%=rs.getString("Farbe")%></td><td><%=rs.getString("Jahrgang")%></td></tr>
      <%} while (rs.next());
      }
    }
  }
  %>
  </table>
</body>
</html>
