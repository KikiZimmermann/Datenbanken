<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Kuenstler</title>
</head>

<body>

<div style="float: right;">
  <a href="${contextPath}/Logout" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Kuenstler</h1>

<form method="GET" action="">
  <p>
    Suche nach Teil vom Künstlernamen:
    <input name="wName" type="text" value="${param.wName}"/>
    <button class="btn btn-primary">Suchen</button>
  </p>
</form>

<a href="${contextPath}/index.jsp">Zur Startseite</a>

<hr/><br/>

<!-- Datenbank -->
<sql:setDataSource dataSource="jdbc/theaterDB" />

<!-- Default: alle Künstler -->
<c:if test="${empty param.wName}">
  <sql:query var="KUENSTLER">
    SELECT * FROM KUENSTLER
  </sql:query>
</c:if>

<!-- Suche nach Name -->
<c:if test="${not empty param.wName}">
  <sql:query var="KUENSTLER">
    SELECT KName, SVNr, Datum
    FROM KUENSTLER
    WHERE KName LIKE ?
    <sql:param value="%${param.wName}%" />
  </sql:query>
</c:if>

<!-- keine Ergebnisse -->
<c:if test="${KUENSTLER.rowCount == 0}">
  <p style="color: red;">Keine Einträge gefunden!</p>
</c:if>

<!-- Tabelle -->
<c:if test="${KUENSTLER.rowCount > 0}">
  <table class="data table-striped">
    <tr>
      <th>Künstlername</th>
      <th>SVNr</th>
      <th>Datum</th>
    </tr>

    <c:forEach var="k" items="${KUENSTLER.rows}">
      <tr>
        <td>${k.kname}</td>
        <td>${k.svnr}</td>
        <td>${k.datum}</td>
      </tr>
    </c:forEach>
  </table>
</c:if>

</body>
</html>