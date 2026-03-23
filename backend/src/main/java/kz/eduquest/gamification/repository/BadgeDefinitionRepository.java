package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.BadgeDefinition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface BadgeDefinitionRepository extends JpaRepository<BadgeDefinition, UUID> {

    List<BadgeDefinition> findByActiveTrue();

    /** Бейджи, которые пользователь ещё не получил */
    @Query("""
            SELECT bd FROM BadgeDefinition bd
            WHERE bd.active = true
              AND bd.id NOT IN (SELECT ub.badge.id FROM UserBadge ub WHERE ub.user.id = :userId)
            """)
    List<BadgeDefinition> findUnearnedByUser(UUID userId);
}
