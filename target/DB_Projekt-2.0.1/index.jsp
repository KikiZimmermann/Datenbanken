<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
    <head>
        <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${contextPath}/css/main.css" />
        <title>Theaterverwaltung</title>
    </head>
    <body>
        <h1>Theaterdatenbank mit Webanbindung</h1>
        <ul>
          <li><a href="kuenstler.jsp">Kuenstler suchen</a>: JSP mit JSTL
          </li>
          <li><a href="neuer-kuenstler.jsp">Kuenstler anlegen</a>: JSP Seite mit Servlet,
            das die Anfrage abarbeitet und dann an ein JSP zur Darstellung des 
            Ergebnisses weiterleitet.</li>
        </ul>
    </body>
</html>
