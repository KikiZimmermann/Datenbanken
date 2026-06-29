<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<c:if test="${empty sessionScope.rolle}">
    <c:redirect url="login.jsp"/>
</c:if>
<c:if test="${sessionScope.rolle != 'besucher'}">
    <c:redirect url="index.jsp"/>
</c:if>

<sql:setDataSource dataSource="jdbc/theaterDB"/>

<c:if test="${param.action == 'stornieren'}">
    <sql:update var="rows">
        DELETE FROM RESERVIEREN WHERE SVNr = ? AND Datum = ? AND Uhrzeit = ?
        <sql:param value="${sessionScope.svnr}"/>
        <sql:param value="${param.datum}"/>
        <sql:param value="${param.uhrzeit}"/>
    </sql:update>
    <c:choose>
        <c:when test="${rows > 0}">
            <c:set var="erfolg" value="Reservierung erfolgreich storniert." scope="session"/>
        </c:when>
        <c:otherwise>
            <c:set var="fehler" value="Reservierung nicht gefunden." scope="session"/>
        </c:otherwise>
    </c:choose>
    <c:redirect url="besucher.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${contextPath}/css/main.css"/>
    <title>Besucher – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
    Angemeldet als: <strong>${sessionScope.besName}</strong>
    (KDNr: ${sessionScope.kdnr}) &nbsp;
    <a href="${contextPath}/logout.jsp" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Theaterverwaltung</h1>
<h2>Willkommen, ${sessionScope.besName}!</h2>

<c:if test="${not empty sessionScope.erfolg}">
    <p style="color: green; font-weight: bold;">${sessionScope.erfolg}</p>
    <c:remove var="erfolg" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.fehler}">
    <p style="color: red;">${sessionScope.fehler}</p>
    <c:remove var="fehler" scope="session"/>
</c:if>

<!-- ===== Lieblingskünstler ===== -->
<h3>Mein Lieblingskünstler</h3>

<sql:query var="LIEBLING">
    SELECT k.KName, k.Datum
    FROM BESUCHER b
    JOIN KUENSTLER k ON b.LieblingsKuenstler = k.SVNr
    WHERE b.SVNr = ?
    <sql:param value="${sessionScope.svnr}"/>
</sql:query>

<c:choose>
    <c:when test="${LIEBLING.rowCount == 0}">
        <p style="color: grey;">Kein Lieblingskünstler eingetragen.</p>
    </c:when>
    <c:otherwise>
        <c:forEach var="l" items="${LIEBLING.rows}">
            <p>&#9733; <strong>${l.kname}</strong></p>
        </c:forEach>
    </c:otherwise>
</c:choose>

<hr/>

<!-- ===== Meine Reservierungen ===== -->
<h3>Meine Reservierungen</h3>

<sql:query var="MEINE_RES">
    SELECT r.Datum, r.Uhrzeit, r.ResNr, r.Sitzplatz, a.Name
    FROM RESERVIEREN r
    JOIN AUFFUEHRUNG a ON r.Datum = a.Datum AND r.Uhrzeit = a.Uhrzeit
    WHERE r.SVNr = ?
    ORDER BY r.Datum, r.Uhrzeit
    <sql:param value="${sessionScope.svnr}"/>
</sql:query>

<c:choose>
    <c:when test="${MEINE_RES.rowCount == 0}">
        <p style="color: grey;">Keine Reservierungen vorhanden.</p>
    </c:when>
    <c:otherwise>
        <table class="data table-striped">
            <tr>
                <th>ResNr</th>
                <th>Theaterstück</th>
                <th>Datum</th>
                <th>Uhrzeit</th>
                <th>Sitzplatz</th>
                <th>Aktion</th>
            </tr>
            <c:forEach var="r" items="${MEINE_RES.rows}">
                <tr>
                    <td>${r.resnr}</td>
                    <td>${r.name}</td>
                    <td>${r.datum}</td>
                    <td>${r.uhrzeit}</td>
                    <td>${r.sitzplatz}</td>
                    <td>
                        <form method="POST" action="${contextPath}/besucher.jsp" style="display:inline;">
                            <input type="hidden" name="action" value="stornieren"/>
                            <input type="hidden" name="datum" value="${r.datum}"/>
                            <input type="hidden" name="uhrzeit" value="${r.uhrzeit}"/>
                            <button type="submit" class="btn btn-secondary"
                                    onclick="return confirm('Reservierung wirklich stornieren?')">
                                Stornieren
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:otherwise>
</c:choose>

<hr/>

<!-- ===== Künstler suchen ===== -->
<h3>Künstler suchen</h3>

<form method="GET" action="">
    <p>
        Künstlername:
        <input name="wName" type="text" value="${param.wName}"/>
        <button class="btn btn-primary">Suchen</button>
    </p>
</form>

<c:if test="${empty param.wName}">
    <sql:query var="KUENSTLER">SELECT KName, Datum FROM KUENSTLER ORDER BY KName</sql:query>
</c:if>
<c:if test="${not empty param.wName}">
    <sql:query var="KUENSTLER">
        SELECT KName, Datum FROM KUENSTLER WHERE KName LIKE ? ORDER BY KName
        <sql:param value="%${param.wName}%"/>
    </sql:query>
</c:if>

<c:choose>
    <c:when test="${KUENSTLER.rowCount == 0}">
        <p style="color: red;">Keine Künstler gefunden.</p>
    </c:when>
    <c:otherwise>
        <table class="data table-striped">
            <tr>
                <th>Künstlername</th>
                <th>Datum</th>
            </tr>
            <c:forEach var="k" items="${KUENSTLER.rows}">
                <tr>
                    <td>${k.kname}</td>
                    <td>${k.datum}</td>
                </tr>
            </c:forEach>
        </table>
    </c:otherwise>
</c:choose>

<hr/>

<!-- ===== Aufführungen suchen und reservieren ===== -->
<h3>Aufführungen</h3>
<p>Klicken Sie auf <em>Reservieren</em>, um einen Platz zu reservieren.</p>

<form method="GET" action="">
    <p>
        Theaterstück:
        <input name="wTitel" type="text" value="${param.wTitel}"/>
        <button class="btn btn-primary">Suchen</button>
    </p>
</form>

<c:if test="${empty param.wTitel}">
    <sql:query var="AUFFUEHRUNGEN">
        SELECT Datum, Uhrzeit, Name, Regisseur FROM AUFFUEHRUNG ORDER BY Datum, Uhrzeit
    </sql:query>
</c:if>
<c:if test="${not empty param.wTitel}">
    <sql:query var="AUFFUEHRUNGEN">
        SELECT Datum, Uhrzeit, Name, Regisseur FROM AUFFUEHRUNG
        WHERE Name LIKE ? ORDER BY Datum, Uhrzeit
        <sql:param value="%${param.wTitel}%"/>
    </sql:query>
</c:if>

<c:choose>
    <c:when test="${AUFFUEHRUNGEN.rowCount == 0}">
        <p style="color: red;">Keine Aufführungen gefunden.</p>
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
                            <button type="submit" class="btn btn-primary">Reservieren</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:otherwise>
</c:choose>

</body>
</html>
