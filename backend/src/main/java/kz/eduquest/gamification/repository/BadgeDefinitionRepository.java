package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.BadgeDefinition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface BadgeDefinitionRepository extends JpaRepository<BadgeDefinition, Long> {

    List<BadgeDefinition> findByActiveTrue();

    @Query("""
            SELECT bd FROM BadgeDefinition bd
            WHERE bd.active = true
              AND bd.id NOT IN (SELECT ub.badge.id FROM UserBadge ub WHERE ub.user.id = :userId)
            """)
    List<BadgeDefinition> findUnearnedByUser(Long userId);
}
