<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<c:if test="${empty sessionScope.rolle}">
    <c:redirect url="login.jsp"/>
</c:if>

<sql:setDataSource dataSource="jdbc/theaterDB"/>

<!-- Aufführungsdaten aus POST in Session speichern -->
<c:if test="${not empty param.datum and empty param.action}">
    <c:set var="aufDatum"   value="${param.datum}"   scope="session"/>
    <c:set var="aufUhrzeit" value="${param.uhrzeit}" scope="session"/>
    <c:set var="aufName"    value="${param.name}"    scope="session"/>
</c:if>

<!-- Reservierung durchführen -->
<c:if test="${param.action == 'reservieren'}">

    <c:if test="${empty sessionScope.aufDatum}">
        <c:set var="fehler" value="Keine Aufführung ausgewählt. Bitte zuerst eine Aufführung wählen." scope="session"/>
        <c:redirect url="besucher.jsp"/>
    </c:if>

    <sql:query var="sitzplatzCheck">
        SELECT COUNT(*) AS cnt FROM RESERVIEREN WHERE Sitzplatz = ?
        <sql:param value="${param.sitzplatz}"/>
    </sql:query>
    <c:forEach var="r" items="${sitzplatzCheck.rows}">
        <c:if test="${r.cnt > 0}">
            <c:set var="fehler" value='Sitzplatz "${param.sitzplatz}" ist bereits reserviert. Bitte einen anderen wählen.' scope="session"/>
            <c:redirect url="reservierung.jsp"/>
        </c:if>
    </c:forEach>

    <sql:query var="dupCheck">
        SELECT COUNT(*) AS cnt FROM RESERVIEREN WHERE SVNr = ? AND Datum = ? AND Uhrzeit = ?
        <sql:param value="${sessionScope.svnr}"/>
        <sql:param value="${sessionScope.aufDatum}"/>
        <sql:param value="${sessionScope.aufUhrzeit}"/>
    </sql:query>
    <c:forEach var="r" items="${dupCheck.rows}">
        <c:if test="${r.cnt > 0}">
            <c:set var="fehler" value="Sie haben für diese Aufführung bereits eine Reservierung." scope="session"/>
            <c:redirect url="reservierung.jsp"/>
        </c:if>
    </c:forEach>

    <sql:query var="nextRes">
        SELECT COALESCE(MAX(ResNr), 0) + 1 AS nextNr FROM RESERVIEREN
    </sql:query>
    <c:forEach var="r" items="${nextRes.rows}">
        <c:set var="resNr" value="${r.nextnr}"/>
    </c:forEach>

    <sql:update>
        INSERT INTO RESERVIEREN (SVNr, Datum, Uhrzeit, ResNr, Sitzplatz) VALUES (?, ?, ?, ?, ?)
        <sql:param value="${sessionScope.svnr}"/>
        <sql:param value="${sessionScope.aufDatum}"/>
        <sql:param value="${sessionScope.aufUhrzeit}"/>
        <sql:param value="${resNr}"/>
        <sql:param value="${param.sitzplatz}"/>
    </sql:update>

    <c:set var="erfolg" scope="session">Reservierung Nr. ${resNr} für Sitzplatz ${param.sitzplatz} erfolgreich angelegt!</c:set>
    <c:remove var="aufDatum"   scope="session"/>
    <c:remove var="aufUhrzeit" scope="session"/>
    <c:remove var="aufName"    scope="session"/>
    <c:redirect url="reservierung.jsp"/>

</c:if>

<!DOCTYPE html>
<html>
<head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${contextPath}/css/main.css"/>
    <title>Reservierung – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
    Angemeldet als: <strong>${sessionScope.besName}</strong> &nbsp;
    <a href="${contextPath}/logout.jsp" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Reservierung</h1>
<a href="${contextPath}/besucher.jsp">Zurück zur Übersicht</a>

<c:if test="${not empty sessionScope.erfolg}">
    <p style="color: green; font-weight: bold;">${sessionScope.erfolg}</p>
    <c:remove var="erfolg" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.fehler}">
    <p style="color: red;">${sessionScope.fehler}</p>
    <c:remove var="fehler" scope="session"/>
</c:if>

<c:choose>
    <c:when test="${not empty sessionScope.aufDatum}">
        <h2>Ausgewählte Aufführung</h2>
        <table class="data">
            <tr>
                <th>Theaterstück</th>
                <th>Datum</th>
                <th>Uhrzeit</th>
            </tr>
            <tr>
                <td>${sessionScope.aufName}</td>
                <td>${sessionScope.aufDatum}</td>
                <td>${sessionScope.aufUhrzeit}</td>
            </tr>
        </table>

        <h2>Sitzplatz wählen</h2>
        <p>Reservierung für: <strong>${sessionScope.besName}</strong> (KDNr: ${sessionScope.kdnr})</p>

        <sql:query var="BELEGT">
            SELECT Sitzplatz FROM RESERVIEREN ORDER BY Sitzplatz
        </sql:query>
        <c:if test="${BELEGT.rowCount > 0}">
            <p style="color: grey;">
                Bereits belegte Sitzplätze:
                <c:forEach var="b" items="${BELEGT.rows}" varStatus="s">
                    <strong>${b.sitzplatz}</strong><c:if test="${!s.last}">, </c:if>
                </c:forEach>
            </p>
        </c:if>

        <form method="POST" action="${contextPath}/reservierung.jsp">
            <input type="hidden" name="action" value="reservieren"/>
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
