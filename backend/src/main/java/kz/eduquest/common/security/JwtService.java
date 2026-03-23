package kz.eduquest.common.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class JwtService {

    private final JwtProperties props;

    /** Blacklisted refresh token JTIs. TODO: заменить на Redis */
    private final Set<String> blacklistedJtis = ConcurrentHashMap.newKeySet();

    public String generateAccessToken(UUID userId, String email, Set<String> roles) {
        return Jwts.builder()
                .subject(userId.toString())
                .claim("email", email)
                .claim("roles", roles)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + props.getAccessExpirationMs()))
                .signWith(getSigningKey())
                .compact();
    }

    public String generateRefreshToken(UUID userId) {
        return Jwts.builder()
                .subject(userId.toString())
                .id(UUID.randomUUID().toString())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + props.getRefreshExpirationMs()))
                .signWith(getSigningKey())
                .compact();
    }

    public Claims parseToken(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean isValid(String token) {
        try {
            Claims claims = parseToken(token);
            String jti = claims.getId();
            return jti == null || !blacklistedJtis.contains(jti);
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public UUID extractUserId(String token) {
        return UUID.fromString(parseToken(token).getSubject());
    }

    public void blacklistRefreshToken(String refreshToken) {
        try {
            Claims claims = parseToken(refreshToken);
            if (claims.getId() != null) {
                blacklistedJtis.add(claims.getId());
            }
        } catch (JwtException ignored) {
            // token already invalid
        }
    }

    public long getAccessExpirationMs() {
        return props.getAccessExpirationMs();
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = props.getSecret().getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
