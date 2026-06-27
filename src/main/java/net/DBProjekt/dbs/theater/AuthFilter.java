package net.DBProjekt.dbs.theater;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

public class AuthFilter implements Filter {

    // Seiten die Besucher (Kunden) sehen dürfen
    private static final Set<String> BESUCHER_PFADE = Set.of(
        "/besucher.jsp", "/auffuehrung.jsp", "/reservierung.jsp", "/Reservierung"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();

        if (path.startsWith("/css/") || path.equals("/login.jsp")
                || path.equals("/Login") || path.equals("/Logout")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        String rolle = (session != null) ? (String) session.getAttribute("rolle") : null;

        if (rolle == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if ("besucher".equals(rolle) && !BESUCHER_PFADE.contains(path)) {
            resp.sendRedirect(req.getContextPath() + "/besucher.jsp");
            return;
        }

        chain.doFilter(request, response);
    }
}
