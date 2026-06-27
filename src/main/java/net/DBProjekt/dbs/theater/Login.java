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

public class Login extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String passwordStr = req.getParameter("password");

        int passwordNr;
        try {
            passwordNr = Integer.parseInt(passwordStr);
        } catch (NumberFormatException e) {
            req.setAttribute("fehler", "Passwort muss eine Zahl sein (Angestelltennummer oder Kundennummer).");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        try {
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/theaterDB");
            try (Connection con = ds.getConnection()) {

                // 1. Angestellter prüfen
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT a.ANGNr, a.SVNr, p.Vorname, p.Nachname " +
                        "FROM ANGESTELLTER a JOIN PERSON p ON a.SVNr = p.SVNr " +
                        "WHERE CONCAT(p.Vorname, ' ', p.Nachname) = ? AND a.ANGNr = ?")) {
                    ps.setString(1, username);
                    ps.setInt(2, passwordNr);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            HttpSession session = req.getSession(true);
                            session.setAttribute("rolle", "angestellter");
                            session.setAttribute("angNr", rs.getInt("ANGNr"));
                            session.setAttribute("svnr", rs.getString("SVNr"));
                            session.setAttribute("angName", rs.getString("Vorname") + " " + rs.getString("Nachname"));
                            resp.sendRedirect(req.getContextPath() + "/index.jsp");
                            return;
                        }
                    }
                }

                // 2. Besucher prüfen
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT b.KDNr, b.SVNr, p.Vorname, p.Nachname " +
                        "FROM BESUCHER b JOIN PERSON p ON b.SVNr = p.SVNr " +
                        "WHERE CONCAT(p.Vorname, ' ', p.Nachname) = ? AND b.KDNr = ?")) {
                    ps.setString(1, username);
                    ps.setInt(2, passwordNr);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            HttpSession session = req.getSession(true);
                            session.setAttribute("rolle", "besucher");
                            session.setAttribute("kdnr", rs.getInt("KDNr"));
                            session.setAttribute("svnr", rs.getString("SVNr"));
                            session.setAttribute("besName", rs.getString("Vorname") + " " + rs.getString("Nachname"));
                            resp.sendRedirect(req.getContextPath() + "/besucher.jsp");
                            return;
                        }
                    }
                }
            }

            req.setAttribute("fehler", "Ungültiger Benutzername oder Passwort.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("fehler", "Datenbankfehler: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
