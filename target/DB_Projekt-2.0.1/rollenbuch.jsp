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

<c:if test="${param.action == 'zurueckgeben'}">
        <sql:update var="anzahl">
            DELETE FROM ENTLEHNUNG WHERE INVNr = ? AND (KuenstlerSVNr = ? OR BuehnenarbeiterSVNr = ?)
            <sql:param value="${param.invnr}"/>
            <sql:param value="${sessionScope.svnr}"/>
            <sql:param value="${sessionScope.svnr}"/>
        </sql:update>
        <c:choose>
            <c:when test="${anzahl == 1}">
                <c:set var="erfolg" value="Rollenbuch (INVNr: ${param.invnr}) erfolgreich zurückgegeben." scope="session"/>
            </c:when>
            <c:otherwise>
                <c:set var="fehler" value="Rollenbuch konnte nicht zurückgegeben werden." scope="session"/>
            </c:otherwise>
        </c:choose>
        <c:redirect url="rollenbuch.jsp"/>
</c:if>

<c:if test="${param.action == 'hinzufuegen'}">
    <sql:query var="invnrCheck">
        SELECT COUNT(*) AS cnt FROM ROLLENBUCH WHERE INVNr = ? AND ISBN = ?
        <sql:param value="${param.invnr}"/>
        <sql:param value="${param.isbn}"/>
    </sql:query>
    <c:forEach var="r" items="${invnrCheck.rows}">
        <c:if test="${r.cnt > 0}">
            <c:set var="fehler" value="INVNr ${param.invnr} existiert für dieses Theaterstück bereits." scope="session"/>
            <c:redirect url="rollenbuch.jsp"/>
        </c:if>
    </c:forEach>

    <sql:update>
        INSERT INTO ROLLENBUCH (INVNr, ISBN) VALUES (?, ?)
        <sql:param value="${param.invnr}"/>
        <sql:param value="${param.isbn}"/>
    </sql:update>
    <c:set var="erfolg" value="Rollenbuch (INVNr: ${param.invnr}) erfolgreich hinzugefügt." scope="session"/>
    <c:redirect url="rollenbuch.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="${contextPath}/css/main.css"/>
    <title>Rollenbücher – Theaterverwaltung</title>
</head>
<body>

<div style="float: right;">
    Angemeldet als: <strong>${sessionScope.angName}</strong> &nbsp;
    <a href="${contextPath}/logout.jsp" class="btn btn-secondary">Abmelden</a>
</div>

<h1>Rollenbücher</h1>
<a href="${contextPath}/index.jsp">Zur Startseite</a>

<c:if test="${not empty sessionScope.fehler}">
    <p style="color: red;">${sessionScope.fehler}</p>
    <c:remove var="fehler" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.erfolg}">
    <p style="color: green; font-weight: bold;">${sessionScope.erfolg}</p>
    <c:remove var="erfolg" scope="session"/>
</c:if>

<h2>Rollenbuch suchen und ausleihen</h2>

<form method="GET" action="">
    <p>
        Suche nach Theaterstück:
        <input name="wStueck" type="text" value="${param.wStueck}"/>
        <button class="btn btn-primary">Suchen</button>
    </p>
</form>

<c:if test="${empty param.wStueck}">
    <sql:query var="BUECHER">
        SELECT r.INVNr, r.ISBN, t.Name,
        e.KuenstlerSVNr, e.BuehnenarbeiterSVNr,
        COALESCE(pk.Vorname, pb.Vorname) AS EntlehnerVorname,
        COALESCE(pk.Nachname, pb.Nachname) AS EntlehnerNachname
        FROM ROLLENBUCH r
        JOIN THEATERSTUECK t ON r.ISBN = t.ISBN
        LEFT JOIN ENTLEHNUNG e ON r.INVNr = e.INVNr
        LEFT JOIN KUENSTLER k ON e.KuenstlerSVNr = k.SVNr
        LEFT JOIN PERSON pk ON k.SVNr = pk.SVNr
        LEFT JOIN BUEHNENARBEITER ba ON e.BuehnenarbeiterSVNr = ba.SVNr
        LEFT JOIN PERSON pb ON ba.SVNr = pb.SVNr
        ORDER BY t.Name, r.INVNr
    </sql:query>
</c:if>
<c:if test="${not empty param.wStueck}">
    <sql:query var="BUECHER">
        SELECT r.INVNr, r.ISBN, t.Name,
        e.KuenstlerSVNr, e.BuehnenarbeiterSVNr,
        COALESCE(pk.Vorname, pb.Vorname) AS EntlehnerVorname,
        COALESCE(pk.Nachname, pb.Nachname) AS EntlehnerNachname
        FROM ROLLENBUCH r
        JOIN THEATERSTUECK t ON r.ISBN = t.ISBN
        LEFT JOIN ENTLEHNUNG e ON r.INVNr = e.INVNr
        LEFT JOIN KUENSTLER k ON e.KuenstlerSVNr = k.SVNr
        LEFT JOIN PERSON pk ON k.SVNr = pk.SVNr
        LEFT JOIN BUEHNENARBEITER ba ON e.BuehnenarbeiterSVNr = ba.SVNr
        LEFT JOIN PERSON pb ON ba.SVNr = pb.SVNr
        WHERE t.Name LIKE ? ORDER BY t.Name, r.INVNr
        <sql:param value="%${param.wStueck}%"/>
    </sql:query>
</c:if>

<c:choose>
    <c:when test="${BUECHER.rowCount == 0}">
        <p style="color: red;">Keine Rollenbücher gefunden.</p>
    </c:when>
    <c:otherwise>
        <table class="data table-striped">
            <tr>
                <th>INVNr</th>
                <th>ISBN</th>
                <th>Theaterstück</th>
                <th>Status</th>
                <th>Aktion</th>
            </tr>
            <c:forEach var="b" items="${BUECHER.rows}">
                <c:set var="ausgeliehen" value="${not empty b.kuenstlersvnr or not empty b.buehnenarbeitersvnr}"/>
                <tr>
                    <td>${b.invnr}</td>
                    <td>${b.isbn}</td>
                    <td>${b.name}</td>
                    <td>
                        <c:choose>
                            <c:when test="${ausgeliehen}">
                                <span style="color: red;">Ausgeliehen</span>
                                <small>(${b.entlehnervorname} ${b.entlehnernachname})</small>
                            </c:when>
                            <c:otherwise>
                                <span style="color: green;">Verfügbar</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${not ausgeliehen}">
                                <form method="POST" action="${contextPath}/ausleihen.jsp" style="display:inline;">
                                    <input type="hidden" name="isbn" value="${b.isbn}"/>
                                    <input type="hidden" name="invnr" value="${b.invnr}"/>
                                    <input type="hidden" name="stueck" value="${b.name}"/>
                                    <button type="submit" class="btn btn-primary">Ausleihen</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form method="POST" action="${contextPath}/rollenbuch.jsp" style="display:inline;">
                                    <input type="hidden" name="action" value="zurueckgeben"/>
                                    <input type="hidden" name="invnr" value="${b.invnr}"/>
                                    <button type="submit" class="btn btn-secondary">Zurückgeben</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:otherwise>
</c:choose>

<hr/>
<h2>Neues Rollenbuch hinzufügen</h2>

<sql:query var="STUECKE">
    SELECT ISBN, Name FROM THEATERSTUECK ORDER BY Name
</sql:query>

<form method="POST" action="${contextPath}/rollenbuch.jsp">
    <input type="hidden" name="action" value="hinzufuegen"/>
    <table>
        <tr>
            <td>INVNr:</td>
            <td><input type="number" name="invnr" class="form-control" required placeholder="z.B. 101"/></td>
        </tr>
        <tr>
            <td>Theaterstück:</td>
            <td>
                <select name="isbn" class="form-control">
                    <c:forEach var="s" items="${STUECKE.rows}">
                        <option value="${s.isbn}">${s.name} (ISBN: ${s.isbn})</option>
                    </c:forEach>
                </select>
            </td>
        </tr>
    </table>
    <div style="margin-top: 10px;">
        <button type="submit" class="btn btn-primary">Hinzufügen</button>
    </div>
</form>

</body>
</html>
