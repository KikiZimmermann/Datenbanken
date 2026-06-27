<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Theaterverwaltung – Angestellter</title>
</head>
<body>

<div style="float: right;">
  Angemeldet als: <strong>${sessionScope.angName}</strong>
  (ANGNr: ${sessionScope.angNr}) &nbsp;
  <a href="${contextPath}/Logout" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Theaterverwaltung</h1>
<h2>Willkommen, ${sessionScope.angName}!</h2>

<h3>Rollenbücher</h3>
<ul>
  <li><a href="${contextPath}/rollenbuch.jsp">Rollenbuch suchen und ausleihen</a></li>
</ul>

<h3>Künstler</h3>
<ul>
  <li><a href="${contextPath}/kuenstler.jsp">Künstler suchen</a></li>
</ul>

</body>
</html>
