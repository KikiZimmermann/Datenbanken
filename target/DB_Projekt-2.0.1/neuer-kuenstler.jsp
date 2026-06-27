<!DOCTYPE html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="net.DBProjekt.dbs.theater.NeuerWein,java.util.Calendar" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<html>
  <head>
    <c:set var="contextPath" value="${pageContext.request.contextPath}"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" href="${contextPath}/css/main.css" />
    <title>Weine</title>
  </head>
  <body>
    <h1>Neuer Wein</h1>
    <% if (request.getAttribute(NeuerWein.ERROR_MSG_PARAM) != null) { %>
      <p style="color: red"><%=request.getAttribute(NeuerWein.ERROR_MSG_PARAM)%></p>
    <% } %>
    <% if (request.getAttribute(NeuerWein.SUCCESS_MSG_PARAM) != null) { %>
      <p style="color: blue"><%=request.getAttribute(NeuerWein.SUCCESS_MSG_PARAM)%></p>
    <% } %>
    <form method="POST" action="${contextPath}/NeuerWein" style="display: inline-block">
      <table>
        <tr><td>Name:</td><td><input type="text" name="name" value="${param.name}" class="form-control"/></td></tr>
        <tr><td>Farbe:</td><td><select name="farbe" class="form-control">
              <option value="Weiß" ${'Weiß' eq param.farbe ? 'selected' : ''}>Weiß</option>
              <option value="Rot" ${'Rot' eq param.farbe ? 'selected' : ''}>Rot</option>
              <option value="Rose" ${'Rose' eq param.farbe ? 'selected' : ''}>Rose</option>
            </select></td></tr>
        <tr><td>Jahrgang:</td><td><input type="number" name="jahrgang" min="1500" class="form-control"
                                         max="<%=Calendar.getInstance().get(Calendar.YEAR)%>"
                                         value="<%=request.getParameter("jahrgang") != null ?
                                                   request.getParameter("jahrgang") : Calendar.getInstance().get(Calendar.YEAR)%>"/></td></tr>
        <sql:setDataSource dataSource="jdbc/WeineDB" />
        <sql:query var="erzeuger" sql="SELECT Weingut FROM ERZEUGER" />
        <tr><td>Weingut:</td><td>
          <select name="weingut" class="form-control">
            <c:forEach var="e" items="${erzeuger.rows}">
              <option value="${e.weingut}" ${e.weingut eq param.weingut ? 'selected' : ''}>${e.weingut}</option>
            </c:forEach>
          </select>
        </td></tr>

        <tr><td>Preis:</td><td><input type="text" name="preis" value="${param.preis}" class="form-control"/></td></tr>

        <tr><td style="padding-top: 5px">JPA verwenden?</td><td style="padding-top: 5px">
            <input type="checkbox" name="useJpa"  ${not empty param.useJpa ? 'checked="true"' : ''}
                    class="form-control"/></td></tr>
      </table>
      
      <div style="float: right; margin-top: 10px">
      <a href="${contextPath}/kuenstler.jsp" class="btn btn-secondary">Abbrechen</a>
      <button class="btn btn-primary" style="margin-left: 10px">Speichern</button>
      </div>
    </form>
    <% if (request.getAttribute(NeuerWein.WEINE) != null) { %>
      <br/>
      <hr />
      <h2>Weine vom Weingut "${param.weingut}"</h2>
      <table class="data table-striped">
        <tr><th>Name</th><th>Farbe</th><th>Jahrgang</th><th>Preis</th></tr>
        <c:forEach var="wein" items="${WEINE_VON_ERZEUGER}">
          <tr><td>${wein.name}</td><td>${wein.farbe}</td><td>${wein.jahrgang}</td><td>${wein.preis}</td></tr>
        </c:forEach>
      </table>
    <%} %>
  </body>
</html>
