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
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.Time;

public class StorniereReservierung extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("rolle") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String svnr = (String) session.getAttribute("svnr");
        String datumStr = req.getParameter("datum");
        String uhrzeitStr = req.getParameter("uhrzeit");

        try {
            Date datum = Date.valueOf(datumStr);
            Time uhrzeit = Time.valueOf(uhrzeitStr);

            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/theaterDB");
            try (Connection con = ds.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                         "DELETE FROM RESERVIEREN WHERE SVNr = ? AND Datum = ? AND Uhrzeit = ?")) {
                ps.setString(1, svnr);
                ps.setDate(2, datum);
                ps.setTime(3, uhrzeit);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    session.setAttribute("erfolg", "Reservierung erfolgreich storniert.");
                } else {
                    session.setAttribute("fehler", "Reservierung nicht gefunden.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("fehler", "Fehler beim Stornieren: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/besucher.jsp");
    }
}
