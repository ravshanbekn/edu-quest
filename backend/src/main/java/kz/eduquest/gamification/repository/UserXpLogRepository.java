package kz.eduquest.gamification.repository;

import kz.eduquest.gamification.entity.ActionType;
import kz.eduquest.gamification.entity.UserXpLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface UserXpLogRepository extends JpaRepository<UserXpLog, Long> {

    Page<UserXpLog> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    boolean existsByUserIdAndActionTypeAndReferenceId(Long userId, ActionType actionType, Long referenceId);

    @Query("SELECT COALESCE(SUM(x.xpAmount), 0) FROM UserXpLog x WHERE x.user.id = :userId")
    int sumXpByUserId(Long userId);
}
