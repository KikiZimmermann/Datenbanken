<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Aufführungen – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
  Angemeldet als: <strong>${sessionScope.angName}</strong> &nbsp;
  <a href="${contextPath}/Logout" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Aufführungen</h1>
<a href="${contextPath}/index.jsp">Zur Startseite</a>

<c:if test="${not empty sessionScope.fehler}">
  <p style="color: red;">${sessionScope.fehler}</p>
  <c:remove var="fehler" scope="session"/>
</c:if>

<h2>Aufführung auswählen und Reservierung anlegen</h2>
<p>Klicken Sie auf <em>Auswählen</em>, um für diese Aufführung eine Reservierung anzulegen.</p>

<form method="GET" action="">
  <p>
    Suche nach Theaterstück:
    <input name="wTitel" type="text" value="${param.wTitel}"/>
    <button class="btn btn-primary">Suchen</button>
  </p>
</form>

<sql:setDataSource dataSource="jdbc/theaterDB" />

<c:if test="${empty param.wTitel}">
  <sql:query var="AUFFUEHRUNGEN">
    SELECT Datum, Uhrzeit, Name, Regisseur FROM AUFFUEHRUNG ORDER BY Datum, Uhrzeit
  </sql:query>
</c:if>
<c:if test="${not empty param.wTitel}">
  <sql:query var="AUFFUEHRUNGEN">
    SELECT Datum, Uhrzeit, Name, Regisseur FROM AUFFUEHRUNG WHERE Name LIKE ? ORDER BY Datum, Uhrzeit
    <sql:param value="%${param.wTitel}%" />
  </sql:query>
</c:if>

<c:choose>
  <c:when test="${AUFFUEHRUNGEN.rowCount == 0}">
    <p style="color: red;">Keine Aufführungen gefunden!</p>
  </c:when>
  <c:otherwise>
    <table class="data table-striped">
      <tr>
        <th>Theaterstück</th>
        <th>Datum</th>
        <th>Uhrzeit</th>
        <th>Regisseur</th>
        <th>Aktion</th>
      </tr>
      <c:forEach var="a" items="${AUFFUEHRUNGEN.rows}">
        <tr>
          <td>${a.name}</td>
          <td>${a.datum}</td>
          <td>${a.uhrzeit}</td>
          <td>${a.regisseur}</td>
          <td>
            <form method="POST" action="${contextPath}/reservierung.jsp" style="display:inline;">
              <input type="hidden" name="datum" value="${a.datum}"/>
              <input type="hidden" name="uhrzeit" value="${a.uhrzeit}"/>
              <input type="hidden" name="name" value="${a.name}"/>
              <button type="submit" class="btn btn-primary">Auswählen</button>
            </form>
          </td>
        </tr>
      </c:forEach>
    </table>
  </c:otherwise>
</c:choose>

</body>
</html>
