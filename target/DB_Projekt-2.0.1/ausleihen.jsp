<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Schritt 2: Rollenbuch-Daten aus POST in Session speichern
    String isbn = request.getParameter("isbn");
    String invnr = request.getParameter("invnr");
    String stueck = request.getParameter("stueck");
    if (isbn != null && invnr != null) {
        session.setAttribute("rbIsbn", isbn);
        session.setAttribute("rbInvnr", invnr);
        session.setAttribute("rbStueck", stueck);
    }
%>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Rollenbuch ausleihen – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
  Angemeldet als: <strong>${sessionScope.angName}</strong> &nbsp;
  <a href="${contextPath}/Logout" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Rollenbuch ausleihen</h1>
<a href="${contextPath}/rollenbuch.jsp">Zurück zur Rollenbuch-Suche</a>

<!-- Meldungen aus Session (nach Redirect) -->
<c:if test="${not empty sessionScope.erfolg}">
  <p style="color: green; font-weight: bold;">${sessionScope.erfolg}</p>
  <c:remove var="erfolg" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.fehler}">
  <p style="color: red;">${sessionScope.fehler}</p>
  <c:remove var="fehler" scope="session"/>
</c:if>

<c:choose>
  <c:when test="${not empty sessionScope.rbIsbn}">
    <h2>Ausgewähltes Rollenbuch</h2>
    <table class="data">
      <tr><th>INVNr</th><th>ISBN</th><th>Theaterstück</th></tr>
      <tr>
        <td>${sessionScope.rbInvnr}</td>
        <td>${sessionScope.rbIsbn}</td>
        <td>${sessionScope.rbStueck}</td>
      </tr>
    </table>

    <h2>Ausleihe bestätigen</h2>
    <!-- SVNr des eingeloggten Angestellten (Schritt 1) wird automatisch verwendet -->
    <p>Entlehner: <strong>${sessionScope.angName}</strong> (ANGNr: ${sessionScope.angNr})</p>

    <form method="POST" action="${contextPath}/Ausleihen">
      <a href="${contextPath}/rollenbuch.jsp" class="btn btn-secondary">Abbrechen</a>
      <button type="submit" class="btn btn-primary" style="margin-left: 10px;">Ausleihe bestätigen</button>
    </form>
  </c:when>
  <c:otherwise>
    <p style="color: orange;">
      Kein Rollenbuch ausgewählt.
      <a href="${contextPath}/rollenbuch.jsp">Bitte hier ein Rollenbuch wählen.</a>
    </p>
  </c:otherwise>
</c:choose>

</body>
</html>
