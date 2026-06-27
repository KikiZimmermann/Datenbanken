<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Schritt 2: Aufführungsdaten aus dem POST in die Session speichern
    String datum = request.getParameter("datum");
    String uhrzeit = request.getParameter("uhrzeit");
    String aufName = request.getParameter("name");
    if (datum != null && uhrzeit != null) {
        session.setAttribute("aufDatum", datum);
        session.setAttribute("aufUhrzeit", uhrzeit);
        session.setAttribute("aufName", aufName);
    }
%>

<html>
<head>
  <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="${contextPath}/css/main.css" />
  <title>Reservierung – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
  Angemeldet als: <strong>${sessionScope.besName}</strong> &nbsp;
  <a href="${contextPath}/Logout" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Reservierung</h1>
<a href="${contextPath}/besucher.jsp">Zurück zur Übersicht</a>

<!-- Meldungen aus Session (nach Redirect) -->
<c:if test="${not empty sessionScope.erfolg}">
  <p style="color: green; font-weight: bold;">${sessionScope.erfolg}</p>
  <c:remove var="erfolg" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.fehler}">
  <p style="color: red;">${sessionScope.fehler}</p>
  <c:remove var="fehler" scope="session"/>
</c:if>

<!-- Ausgewählte Aufführung aus Session (gesetzt in Schritt 2) -->
<c:choose>
  <c:when test="${not empty sessionScope.aufDatum}">
    <h2>Ausgewählte Aufführung</h2>
    <table class="data">
      <tr><th>Theaterstück</th><th>Datum</th><th>Uhrzeit</th></tr>
      <tr>
        <td>${sessionScope.aufName}</td>
        <td>${sessionScope.aufDatum}</td>
        <td>${sessionScope.aufUhrzeit}</td>
      </tr>
    </table>

    <h2>Sitzplatz wählen</h2>
    <!-- SVNr des eingeloggten Besuchers (Schritt 1) wird automatisch verwendet -->
    <p>Reservierung für: <strong>${sessionScope.besName}</strong> (KDNr: ${sessionScope.kdnr})</p>

    <form method="POST" action="${contextPath}/Reservierung">
      <table>
        <tr>
          <td>Sitzplatz:</td>
          <td><input type="text" name="sitzplatz" class="form-control" required placeholder="z.B. A12"/></td>
        </tr>
      </table>
      <div style="margin-top: 10px;">
        <a href="${contextPath}/besucher.jsp" class="btn btn-secondary">Abbrechen</a>
        <button type="submit" class="btn btn-primary" style="margin-left: 10px;">Reservierung bestätigen</button>
      </div>
    </form>
  </c:when>
  <c:otherwise>
    <p style="color: orange;">
      Keine Aufführung ausgewählt.
      <a href="${contextPath}/besucher.jsp">Bitte hier eine Aufführung wählen.</a>
    </p>
  </c:otherwise>
</c:choose>

</body>
</html>
