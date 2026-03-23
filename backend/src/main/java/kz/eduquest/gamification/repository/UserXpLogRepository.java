package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.ActionType;
import kz.eduquest.gamification.entity.UserXpLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.UUID;

public interface UserXpLogRepository extends JpaRepository<UserXpLog, UUID> {

    Page<UserXpLog> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    boolean existsByUserIdAndActionTypeAndReferenceId(UUID userId, ActionType actionType, UUID referenceId);

    @Query("SELECT COALESCE(SUM(x.xpAmount), 0) FROM UserXpLog x WHERE x.user.id = :userId")
    int sumXpByUserId(UUID userId);
}
