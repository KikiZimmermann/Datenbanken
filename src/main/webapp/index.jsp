<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
    <head>
        <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="${contextPath}/css/main.css" />
        <title>Weinverwaltung</title>
    </head>
    <body>
        <h1>Weindatenbank mit Webanbindung</h1>
        <ul>
          <li><a href="kuenstler.jsp">Weine suchen</a>: JSP mit JSTL
            <ul><li>
            <a href="weine_no_jstl.jsp">alternative Implementierung ohne JSTL</a> 
            und damit einigem Java Code im JSP zwecks Vergleich &ndash; 
            Java Code in JSPs wird generell aber als schlechter Programmierstil
            betrachtet und sollte möglichst vermieden werden.
              </li></ul>
          </li>
          <li><a href="neuer-wein.jsp">Wein anlegen</a>: JSP Seite mit Servlet, 
            das die Anfrage abarbeitet und dann an ein JSP zur Darstellung des 
            Ergebnisses weiterleitet.</li>
        </ul>
    </body>
</html>
