<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Anmeldung – Theaterverwaltung</title>
</head>
<body>

<h1>Theaterverwaltung</h1>
<h2>Anmeldung</h2>

<c:if test="${not empty requestScope.fehler}">
  <p style="color: red;">${requestScope.fehler}</p>
</c:if>

<form method="POST" action="${contextPath}/Login" style="display: inline-block;">
  <table>
    <tr>
      <td>Benutzername:</td>
      <td><input type="text" name="username" class="form-control" autofocus
                 placeholder="Vorname Nachname"/></td>
    </tr>
    <tr>
      <td>Passwort:</td>
      <td><input type="password" name="password" class="form-control"
                 placeholder="Angestelltennummer oder Kundennummer"/></td>
    </tr>
  </table>
  <div style="margin-top: 10px;">
    <button class="btn btn-primary">Anmelden</button>
  </div>
</form>

<br/><br/>
<small style="color: grey;">
  Angestellte: Passwort = Angestelltennummer (ANGNr)<br/>
  Besucher: Passwort = Kundennummer (KDNr)
</small>

</body>
</html>
