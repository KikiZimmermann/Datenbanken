<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:remove var="rolle"      scope="session"/>
<c:remove var="angNr"      scope="session"/>
<c:remove var="svnr"       scope="session"/>
<c:remove var="angName"    scope="session"/>
<c:remove var="kdnr"       scope="session"/>
<c:remove var="besName"    scope="session"/>
<c:remove var="rbIsbn"     scope="session"/>
<c:remove var="rbInvnr"    scope="session"/>
<c:remove var="rbStueck"   scope="session"/>
<c:remove var="aufDatum"   scope="session"/>
<c:remove var="aufUhrzeit" scope="session"/>
<c:remove var="aufName"    scope="session"/>

<c:redirect url="login.jsp"/>
