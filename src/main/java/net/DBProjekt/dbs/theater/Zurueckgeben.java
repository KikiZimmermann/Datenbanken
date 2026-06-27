package net.DBProjekt.dbs.theater;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class Zurueckgeben extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || !"angestellter".equals(session.getAttribute("rolle"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String invnrStr = req.getParameter("invnr");
        try {
            int invnr = Integer.parseInt(invnrStr);
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/theaterDB");
            try (Connection con = ds.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                         "DELETE FROM ENTLEHNUNG WHERE INVNr = ?")) {
                ps.setInt(1, invnr);
                ps.executeUpdate();
            }
            session.setAttribute("erfolg", "Rollenbuch (INVNr: " + invnr + ") erfolgreich zurückgegeben.");
        } catch (Exception e) {
            session.setAttribute("fehler", "Fehler beim Zurückgeben: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/rollenbuch.jsp");
    }
}
