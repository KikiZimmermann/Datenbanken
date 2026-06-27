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
import java.sql.ResultSet;
import java.sql.Time;

public class Reservierung extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("rolle") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String datumStr = (String) session.getAttribute("aufDatum");
        String uhrzeitStr = (String) session.getAttribute("aufUhrzeit");
        // SVNr kommt aus der Session (eingeloggter Besucher, Schritt 1)
        String svnr = (String) session.getAttribute("svnr");
        String sitzplatz = req.getParameter("sitzplatz");

        if (datumStr == null || uhrzeitStr == null) {
            session.setAttribute("fehler", "Keine Aufführung ausgewählt. Bitte zuerst eine Aufführung wählen.");
            resp.sendRedirect(req.getContextPath() + "/auffuehrung.jsp");
            return;
        }

        try {
            Date datum = Date.valueOf(datumStr);
            Time uhrzeit = Time.valueOf(uhrzeitStr);

            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/theaterDB");
            try (Connection con = ds.getConnection()) {

                // Sitzplatz bereits vergeben? (UNIQUE Sitzplatz)
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) FROM RESERVIEREN WHERE Sitzplatz = ?")) {
                    ps.setString(1, sitzplatz);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            session.setAttribute("fehler",
                                    "Sitzplatz \"" + sitzplatz + "\" ist bereits reserviert. Bitte einen anderen wählen.");
                            resp.sendRedirect(req.getContextPath() + "/reservierung.jsp");
                            return;
                        }
                    }
                }

                // Besucher hat bereits Reservierung für diese Aufführung? (PK-Constraint)
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) FROM RESERVIEREN WHERE SVNr = ? AND Datum = ? AND Uhrzeit = ?")) {
                    ps.setString(1, svnr);
                    ps.setDate(2, datum);
                    ps.setTime(3, uhrzeit);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            session.setAttribute("fehler",
                                    "Sie haben für diese Aufführung bereits eine Reservierung.");
                            resp.sendRedirect(req.getContextPath() + "/reservierung.jsp");
                            return;
                        }
                    }
                }

                int resNr;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COALESCE(MAX(ResNr), 0) + 1 FROM RESERVIEREN");
                     ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    resNr = rs.getInt(1);
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO RESERVIEREN (SVNr, Datum, Uhrzeit, ResNr, Sitzplatz) VALUES (?, ?, ?, ?, ?)")) {
                    ps.setString(1, svnr);
                    ps.setDate(2, datum);
                    ps.setTime(3, uhrzeit);
                    ps.setInt(4, resNr);
                    ps.setString(5, sitzplatz);
                    ps.executeUpdate();
                }
                session.setAttribute("erfolg", "Reservierung Nr. " + resNr +
                        " für Sitzplatz " + sitzplatz + " erfolgreich angelegt!");
                session.removeAttribute("aufDatum");
                session.removeAttribute("aufUhrzeit");
                session.removeAttribute("aufName");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("fehler", "Ungültiges Datum/Uhrzeit-Format: " + e.getMessage());
        } catch (Exception e) {
            session.setAttribute("fehler", "Fehler bei der Reservierung: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/reservierung.jsp");
    }
}
