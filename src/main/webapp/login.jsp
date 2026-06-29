<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<sql:setDataSource dataSource="jdbc/theaterDB"/>

<c:if test="${not empty param.username}">

    <sql:query var="loginAng">
        SELECT a.ANGNr, a.SVNr, p.Vorname, p.Nachname
        FROM ANGESTELLTER a JOIN PERSON p ON a.SVNr = p.SVNr
        WHERE CONCAT(p.Vorname, ' ', p.Nachname) = ? AND a.ANGNr = ?
        <sql:param value="${param.username}"/>
        <sql:param value="${param.password}"/>
    </sql:query>

    <c:if test="${loginAng.rowCount == 1}">
        <c:forEach var="u" items="${loginAng.rows}">
            <c:set var="rolle" value="angestellter" scope="session"/>
            <c:set var="angNr" value="${u.angnr}" scope="session"/>
            <c:set var="svnr" value="${u.svnr}" scope="session"/>
            <c:set var="angName" scope="session">${u.vorname} ${u.nachname}</c:set>
        </c:forEach>
        <jsp:forward page="index.jsp"/>
    </c:if>

    <sql:query var="loginBes">
        SELECT b.KDNr, b.SVNr, p.Vorname, p.Nachname
        FROM BESUCHER b JOIN PERSON p ON b.SVNr = p.SVNr
        WHERE CONCAT(p.Vorname, ' ', p.Nachname) = ? AND b.KDNr = ?
        <sql:param value="${param.username}"/>
        <sql:param value="${param.password}"/>
    </sql:query>

    <c:if test="${loginBes.rowCount == 1}">
        <c:forEach var="u" items="${loginBes.rows}">
            <c:set var="rolle" value="besucher" scope="session"/>
            <c:set var="kdnr" value="${u.kdnr}" scope="session"/>
            <c:set var="svnr" value="${u.svnr}" scope="session"/>
            <c:set var="besName" scope="session">${u.vorname} ${u.nachname}</c:set>
        </c:forEach>
        <jsp:forward page="besucher.jsp"/>
    </c:if>

    <c:set var="fehler" value="Ungültiger Benutzername oder Passwort." scope="request"/>

</c:if>

<!DOCTYPE html>
<html>
<head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${contextPath}/css/main.css"/>
    <title>Anmeldung – Theaterverwaltung</title>
</head>
<body>

<h1>Theaterverwaltung</h1>
<h2>Anmeldung</h2>

<c:if test="${not empty requestScope.fehler}">
    <p style="color: red;">${requestScope.fehler}</p>
</c:if>

<form method="POST" action="" style="display: inline-block;">
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
