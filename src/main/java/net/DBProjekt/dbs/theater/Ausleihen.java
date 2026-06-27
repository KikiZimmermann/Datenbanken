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
import java.sql.ResultSet;

public class Ausleihen extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        if (session == null || !"angestellter".equals(session.getAttribute("rolle"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Schritt 1: SVNr des eingeloggten Angestellten
        String svnr = (String) session.getAttribute("svnr");
        // Schritt 2: ausgewähltes Rollenbuch
        String invnrStr = (String) session.getAttribute("rbInvnr");

        if (invnrStr == null) {
            session.setAttribute("fehler", "Kein Rollenbuch ausgewählt.");
            resp.sendRedirect(req.getContextPath() + "/rollenbuch.jsp");
            return;
        }

        try {
            int invnr = Integer.parseInt(invnrStr);
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/theaterDB");
            try (Connection con = ds.getConnection()) {

                // Prüfen ob Rollenbuch bereits ausgeliehen
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) FROM ENTLEHNUNG WHERE INVNr = ?")) {
                    ps.setInt(1, invnr);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            session.setAttribute("fehler", "Rollenbuch (INVNr: " + invnr + ") ist bereits ausgeliehen.");
                            resp.sendRedirect(req.getContextPath() + "/rollenbuch.jsp");
                            return;
                        }
                    }
                }

                // Prüfen ob Künstler oder Bühnenarbeiter
                boolean istKuenstler = false;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) FROM KUENSTLER WHERE SVNr = ?")) {
                    ps.setString(1, svnr);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        istKuenstler = rs.getInt(1) > 0;
                    }
                }

                if (istKuenstler) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO ENTLEHNUNG (INVNr, KuenstlerSVNr, BuehnenarbeiterSVNr) VALUES (?, ?, NULL)")) {
                        ps.setInt(1, invnr);
                        ps.setString(2, svnr);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO ENTLEHNUNG (INVNr, KuenstlerSVNr, BuehnenarbeiterSVNr) VALUES (?, NULL, ?)")) {
                        ps.setInt(1, invnr);
                        ps.setString(2, svnr);
                        ps.executeUpdate();
                    }
                }

                session.setAttribute("erfolg", "Rollenbuch (INVNr: " + invnr + ") erfolgreich ausgeliehen!");
                session.removeAttribute("rbIsbn");
                session.removeAttribute("rbInvnr");
                session.removeAttribute("rbStueck");
            }
        } catch (Exception e) {
            session.setAttribute("fehler", "Fehler beim Ausleihen: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/ausleihen.jsp");
    }
}
