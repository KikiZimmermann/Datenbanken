<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<c:if test="${empty sessionScope.rolle}">
    <c:redirect url="login.jsp"/>
</c:if>
<c:if test="${sessionScope.rolle != 'angestellter'}">
    <c:redirect url="besucher.jsp"/>
</c:if>

<sql:setDataSource dataSource="jdbc/theaterDB"/>

<!-- Rollenbuch-Daten aus POST in Session speichern -->
<c:if test="${not empty param.isbn}">
    <c:set var="rbIsbn"   value="${param.isbn}"   scope="session"/>
    <c:set var="rbInvnr"  value="${param.invnr}"  scope="session"/>
    <c:set var="rbStueck" value="${param.stueck}"  scope="session"/>
</c:if>

<!-- Ausleihe durchführen -->
<c:if test="${param.action == 'bestaetigen'}">

    <c:if test="${empty sessionScope.rbInvnr}">
        <c:set var="fehler" value="Kein Rollenbuch ausgewählt." scope="session"/>
        <c:redirect url="rollenbuch.jsp"/>
    </c:if>

    <sql:query var="entlCheck">
        SELECT COUNT(*) AS cnt FROM ENTLEHNUNG WHERE INVNr = ? AND ISBN = ?
        <sql:param value="${sessionScope.rbInvnr}"/>
        <sql:param value="${sessionScope.rbIsbn}"/>
    </sql:query>
    <c:forEach var="r" items="${entlCheck.rows}">
        <c:if test="${r.cnt > 0}">
            <c:set var="fehler" value="Rollenbuch (INVNr: ${sessionScope.rbInvnr}) ist bereits ausgeliehen." scope="session"/>
            <c:redirect url="rollenbuch.jsp"/>
        </c:if>
    </c:forEach>

    <sql:query var="kuenstlerCheck">
        SELECT COUNT(*) AS cnt FROM KUENSTLER WHERE SVNr = ?
        <sql:param value="${sessionScope.svnr}"/>
    </sql:query>
    <c:set var="istKuenstler" value="false"/>
    <c:forEach var="r" items="${kuenstlerCheck.rows}">
        <c:if test="${r.cnt > 0}">
            <c:set var="istKuenstler" value="true"/>
        </c:if>
    </c:forEach>

    <c:choose>
        <c:when test="${istKuenstler}">
            <sql:update>
                INSERT INTO ENTLEHNUNG (INVNr, ISBN, KuenstlerSVNr, BuehnenarbeiterSVNr) VALUES (?, ?, ?, NULL)
                <sql:param value="${sessionScope.rbInvnr}"/>
                <sql:param value="${sessionScope.rbIsbn}"/>
                <sql:param value="${sessionScope.svnr}"/>
            </sql:update>
        </c:when>
        <c:otherwise>
            <sql:update>
                INSERT INTO ENTLEHNUNG (INVNr, ISBN, KuenstlerSVNr, BuehnenarbeiterSVNr) VALUES (?, ?, NULL, ?)
                <sql:param value="${sessionScope.rbInvnr}"/>
                <sql:param value="${sessionScope.rbIsbn}"/>
                <sql:param value="${sessionScope.svnr}"/>
            </sql:update>
        </c:otherwise>
    </c:choose>

    <c:set var="erfolg" value="Rollenbuch (INVNr: ${sessionScope.rbInvnr}) erfolgreich ausgeliehen!" scope="session"/>
    <c:remove var="rbIsbn"   scope="session"/>
    <c:remove var="rbInvnr"  scope="session"/>
    <c:remove var="rbStueck" scope="session"/>
    <c:redirect url="ausleihen.jsp"/>

</c:if>

<!DOCTYPE html>
<html>
<head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${contextPath}/css/main.css"/>
    <title>Rollenbuch ausleihen – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
    Angemeldet als: <strong>${sessionScope.angName}</strong> &nbsp;
    <a href="${contextPath}/logout.jsp" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Rollenbuch ausleihen</h1>
<a href="${contextPath}/rollenbuch.jsp">Zurück zur Rollenbuch-Suche</a>

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
            <tr>
                <th>INVNr</th>
                <th>ISBN</th>
                <th>Theaterstück</th>
            </tr>
            <tr>
                <td>${sessionScope.rbInvnr}</td>
                <td>${sessionScope.rbIsbn}</td>
                <td>${sessionScope.rbStueck}</td>
            </tr>
        </table>

        <h2>Ausleihe bestätigen</h2>
        <p>Entlehner: <strong>${sessionScope.angName}</strong> (ANGNr: ${sessionScope.angNr})</p>

        <form method="POST" action="${contextPath}/ausleihen.jsp">
            <input type="hidden" name="action" value="bestaetigen"/>
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
